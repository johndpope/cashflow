// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "AppDelegate.h"
#import "AssetListVC.h"
#import "Asset.h"
#import "AssetVC.h"
#import "TransactionListVC.h"
//#import "CategoryListVC.h"
#import "ReportVC.h"
#import "InfoVC.h"
#import "BackupVC.h"
#import "PinController.h"
#import "ConfigViewController.h"

@interface AssetListViewController()
- (void)_dataModelLoadedOnMainThread:(id)dummy;
- (int)_firstShowAssetIndex;
- (void)_setFirstShowAssetIndex:(int)assetIndex;
- (void)_showInitialAsset;
- (int)_assetIndex:(NSIndexPath*)indexPath;
- (void)_actionDelete:(NSInteger)buttonIndex;
- (void)_actionActionButton:(NSInteger)buttonIndex;
@end

@implementation AssetListViewController
{
    BOOL mIsLoadDone;
    DBLoadingView *mLoadingView;
    
    Ledger *mLedger;

    NSMutableArray *mIconArray;

    BOOL mAsDisplaying;
    UIActionSheet *mAsActionButton;
    UIActionSheet *mAsDelete;

    Asset *mAssetToBeDelete;
    
    BOOL mPinChecked;
}

@synthesize tableView = mTableView;

- (void)viewDidLoad
{
    NSLog(@"AssetListViewController:viewDidLoad");
    [super viewDidLoad];
    
    //[AppDelegate trackPageview:@"/AssetListViewController"];
     
    mTableView.rowHeight = 48;
    mPinChecked = NO;
    mAsDisplaying = NO;
    
    mLedger = nil;
	
    // title 設定
    self.title = _L(@"Assets");
	
    // "+" ボタンを追加
    UIBarButtonItem *plusButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                      target:self
                                      action:@selector(addAsset)];
	
    self.navigationItem.rightBarButtonItem = plusButton;
	
    // Edit ボタンを追加
    self.navigationItem.leftBarButtonItem = [self editButtonItem];
	
    // icon image をロード
    mIconArray = [NSMutableArray new];
    int n = [Asset numAssetTypes];

    for (int i = 0; i < n; i++) {
        NSString *iconName = [Asset iconNameWithType:i];
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:iconName ofType:@"png"];
        UIImage *icon = [UIImage imageWithContentsOfFile:imagePath];
        ASSERT(icon != nil);
        [mIconArray addObject:icon];
    }

    if (IS_IPAD) {
        CGSize s = self.contentSizeForViewInPopover;
        s.height = 600;
        self.contentSizeForViewInPopover = s;
    }
    
    // データロード開始
    DataModel *dm = [DataModel instance];
    mIsLoadDone = dm.isLoadDone;
    if (!mIsLoadDone) {
        [dm startLoad:self];
    
        // Loading View を表示させる
        mLoadingView = [[DBLoadingView alloc] initWithTitle:@"Loading"];
        [mLoadingView setOrientation:self.interfaceOrientation];
        mLoadingView.userInteractionEnabled = YES; // 下の View の操作不可にする
        [mLoadingView show];
    }
}

- (void)viewDidUnload {
    NSLog(@"AssetLivewViewController:viewDidUnload");
    mIconArray = nil;

    mTableView = nil;
    mBarActionButton = nil;
    mBarSumLabel = nil;
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
    NSLog(@"AssetListViewController:didReceiveMemoryWarning");
    [super didReceiveMemoryWarning];
}

#pragma mark DataModelDelegate
- (void)dataModelLoaded
{
    NSLog(@"AssetListViewController:dataModelLoaded");

    mIsLoadDone = YES;
    mLedger = [DataModel ledger];
    
    [self performSelectorOnMainThread:@selector(_dataModelLoadedOnMainThread:) withObject:nil waitUntilDone:NO];
}

- (void)_dataModelLoadedOnMainThread:(id)dummy
{
    // dismiss loading view
    [mLoadingView dismissAnimated:NO];
    mLoadingView = nil;

    [self reload];
 
   /*
      '12/3/15
      安定性向上のため、iPad 以外では最後に使った資産に遷移しないようにした。
      起動時に TransactionListVC で固まるケースが多いため。
    */
    if (IS_IPAD) {
        [self _showInitialAsset];
    }
}

- (int)_firstShowAssetIndex
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults integerForKey:@"firstShowAssetIndex"];
}

- (void)_setFirstShowAssetIndex:(int)assetIndex
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:assetIndex forKey:@"firstShowAssetIndex"];
    [defaults synchronize];
}

/**
 * 最後に使用した資産を表示
 */
- (void)_showInitialAsset
{
    int firstShowAssetIndex = [self _firstShowAssetIndex];
    
    Asset *asset = nil;
    if (firstShowAssetIndex >= 0 && [mLedger assetCount] > firstShowAssetIndex) {
        asset = [mLedger assetAtIndex:firstShowAssetIndex];
    }
    if (IS_IPAD && asset == nil && [mLedger assetCount] > 0) {
        asset = [mLedger assetAtIndex:0];
    }

    // TransactionListView を表示
    if (asset != nil) {
        if (IS_IPAD) {
            mSplitTransactionListViewController.assetKey = asset.pid;
            [mSplitTransactionListViewController reload];
        } else { 
            TransactionListViewController *vc = 
                [[TransactionListViewController alloc] init];
            vc.assetKey = asset.pid;
            [self.navigationController pushViewController:vc animated:NO];
        }
    }
}

- (void)reload
{
    if (!mIsLoadDone) return;
    
    mLedger = [DataModel ledger];
    [mLedger rebuild];
    [mTableView reloadData];

    // 合計欄
    double value = 0.0;
    for (int i = 0; i < [mLedger assetCount]; i++) {
        value += [[mLedger assetAtIndex:i] lastBalance];
    }
    NSString *lbl = [NSString stringWithFormat:@"%@ %@", _L(@"Total"), [CurrencyManager formatCurrency:value]];
    mBarSumLabel.title = lbl;
    
    [[Database instance] updateModificationDate]; // TODO : ここでやるのは正しくないが、、、
}

- (void)viewWillAppear:(BOOL)animated
{
    //NSLog(@"AssetListViewController:viewWillAppear");
    
    [super viewWillAppear:animated];
    [self reload];
}

- (void)viewDidAppear:(BOOL)animated
{
    //NSLog(@"AssetListViewController:viewDidAppear");

    static BOOL isInitial = YES;

    [super viewDidAppear:animated];

    if (isInitial) {
         isInitial = NO;
     } 
    else if (!IS_IPAD) {
        // 初回以外：初期起動する画面を資産一覧画面に戻しておく
        [self _setFirstShowAssetIndex:-1];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
}

- (void)viewDidDisappear:(BOOL)animated {
#if 0
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
#endif
}

#pragma mark TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv {
    return 1;
    
    //if (tv.editing) return 1 else return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!mIsLoadDone) return 0;
    
    switch (section) {
        case 0:
            return [mLedger assetCount];
            
        //case 1:
        //    return 1; // 合計欄
    }
    // NOT REACH HERE
    return 0;
}

- (int)_assetIndex:(NSIndexPath*)indexPath
{
    if (indexPath.section == 0) {
        return indexPath.row;
    }
    return -1;
}

- (CGFloat)tableView:(UITableView *)tv heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return tv.rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;

    NSString *cellid = @"assetCell";
    cell = [tv dequeueReusableCellWithIdentifier:cellid];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
        cell.textLabel.font = [UIFont systemFontOfSize:16.0];
    }

    // 資産
    double value = 0;
    NSString *label = nil;

    if (indexPath.section == 0) {
        Asset *asset = [mLedger assetAtIndex:[self _assetIndex:indexPath]];
    
        label = asset.name;
        value = [asset lastBalance];

        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        cell.imageView.image = [mIconArray objectAtIndex:asset.type];
    }
#if 0
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            // 合計欄
            value = 0.0;
            int i;
            for (i = 0; i < [ledger assetCount]; i++) {
                value += [[ledger assetAtIndex:i] lastBalance];
            }
            label = [NSString stringWithFormat:@"            %@", _L(@"Total")];

            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.imageView.image = nil;
        }
    }
#endif
    
    NSString *c = [CurrencyManager formatCurrency:value];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ : %@", label, c];
    
    if (value >= 0) {
        cell.textLabel.textColor = [UIColor blackColor];
    } else {
        cell.textLabel.textColor = [UIColor redColor];
    }
	
    return cell;
}

#pragma mark UITableViewDelegate

//
// セルをクリックしたときの処理
//
- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tv deselectRowAtIndexPath:indexPath animated:NO];

    int assetIndex = [self _assetIndex:indexPath];
    if (assetIndex < 0) return;

    // 最後に選択した asset を記憶
    [self _setFirstShowAssetIndex:assetIndex];
	
    Asset *asset = [mLedger assetAtIndex:assetIndex];

    // TransactionListView を表示
    if (IS_IPAD) {
        mSplitTransactionListViewController.assetKey = asset.pid;
        [mSplitTransactionListViewController reload];
    } else {
        TransactionListViewController *vc = 
            [[TransactionListViewController alloc] init];
        vc.assetKey = asset.pid;

        [self.navigationController pushViewController:vc animated:YES];
    }
}

// アクセサリボタンをタップしたときの処理 : アセット変更
- (void)tableView:(UITableView *)tv accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    AssetViewController *vc = [[AssetViewController alloc] init];
    int assetIndex = [self _assetIndex:indexPath];
    if (assetIndex >= 0) {
        [vc setAssetIndex:indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

// 新規アセット追加
- (void)addAsset
{
    AssetViewController *vc = [[AssetViewController alloc] init];
    [vc setAssetIndex:-1];
    [self.navigationController pushViewController:vc animated:YES];
}

// Editボタン処理
- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
	
    // tableView に通知
    [self.tableView setEditing:editing animated:editing];
	
    if (editing) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

- (BOOL)tableView:(UITableView*)tv canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self _assetIndex:indexPath] < 0)
        return NO;
    return YES;
}

// 編集スタイルを返す
- (UITableViewCellEditingStyle)tableView:(UITableView*)tv editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self _assetIndex:indexPath] < 0) {
        return UITableViewCellEditingStyleNone;
    }
    return UITableViewCellEditingStyleDelete;
}

// 削除処理
- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)style forRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (style == UITableViewCellEditingStyleDelete) {
        int assetIndex = [self _assetIndex:indexPath];
        mAssetToBeDelete = [mLedger assetAtIndex:assetIndex];

        mAsDelete =
            [[UIActionSheet alloc]
                initWithTitle:_L(@"ReallyDeleteAsset")
                delegate:self
                cancelButtonTitle:@"Cancel"
                destructiveButtonTitle:_L(@"Delete Asset")
                otherButtonTitles:nil];
        mAsDelete.actionSheetStyle = UIActionSheetStyleDefault;
        [mAsDelete showInView:self.view];
    }
}

- (void)_actionDelete:(NSInteger)buttonIndex
{
    if (buttonIndex != 0) {
        return; // cancelled;
    }
	
    int pid = mAssetToBeDelete.pid;
    [mLedger deleteAsset:mAssetToBeDelete];
    
    if (IS_IPAD) {
        if (mSplitTransactionListViewController.assetKey == pid) {
            mSplitTransactionListViewController.assetKey = -1;
            [mSplitTransactionListViewController reload];
        }
    }

    [self.tableView reloadData];
}

// 並べ替え処理
- (BOOL)tableView:(UITableView *)tv canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self _assetIndex:indexPath] < 0) {
        return NO;
    }
    return YES;
}

- (NSIndexPath *)tableView:(UITableView *)tv
targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)fromIndexPath 
       toProposedIndexPath:(NSIndexPath *)proposedIndexPath
{
    // 合計額(section:1)には移動させない
    NSIndexPath *idx = [NSIndexPath indexPathForRow:proposedIndexPath.row inSection:0];
    return idx;
}

- (void)tableView:(UITableView *)tv moveRowAtIndexPath:(NSIndexPath*)from toIndexPath:(NSIndexPath*)to
{
    int fromIndex = [self _assetIndex:from];
    int toIndex = [self _assetIndex:to];
    if (fromIndex < 0 || toIndex < 0) return;

    [[DataModel ledger] reorderAsset:fromIndex to:toIndex];
}

//////////////////////////////////////////////////////////////////////////////////////////
// Report

#pragma mark Show Report

- (void)showReport:(id)sender
{
    ReportViewController *reportVC = [[ReportViewController alloc] initWithAsset:nil];
    
    UINavigationController *nv = [[UINavigationController alloc] initWithRootViewController:reportVC];
    if (IS_IPAD) {
        nv.modalPresentationStyle = UIModalPresentationPageSheet;
    }
    [self.navigationController presentModalViewController:nv animated:YES];
}


//////////////////////////////////////////////////////////////////////////////////////////
// Action Sheet 処理

#pragma mark Action Sheet

- (void)doAction:(id)sender
{
    if (mAsDisplaying) return;
    mAsDisplaying = YES;
    
    mAsActionButton = 
        [[UIActionSheet alloc]
         initWithTitle:@"" delegate:self 
         cancelButtonTitle:_L(@"Cancel")
         destructiveButtonTitle:nil
         otherButtonTitles:
         [NSString stringWithFormat:@"%@ (%@)", _L(@"Export"), _L(@"All assets")],
         [NSString stringWithFormat:@"%@ / %@", _L(@"Sync"), _L(@"Backup")],
         _L(@"Config"),
         _L(@"Info"),
         nil];
    if (IS_IPAD) {
        [mAsActionButton showFromBarButtonItem:mBarActionButton animated:YES];
    } else {
        [mAsActionButton showInView:[self view]];
    }
}

- (void)_actionActionButton:(NSInteger)buttonIndex
{
    ExportVC *exportVC;
    ConfigViewController *configVC;
    InfoVC *infoVC;
    BackupViewController *backupVC;
    UIViewController *vc;
    
    mAsDisplaying = NO;
    
    switch (buttonIndex) {
        case 0:
            exportVC = [[ExportVC alloc] initWithAsset:nil];
            vc = exportVC;
            break;
            
        case 1:
            backupVC = [BackupViewController backupViewController:self];
            vc = backupVC;
            break;
            
        case 2:
            configVC = [[ConfigViewController alloc] init];
            vc = configVC;
            break;
            
        case 3:
            infoVC = [[InfoVC alloc] init];
            vc = infoVC;
            break;
            
        default:
            return;
    }
    
    UINavigationController *nv = [[UINavigationController alloc] initWithRootViewController:vc];
    if (IS_IPAD) {
        nv.modalPresentationStyle = UIModalPresentationFormSheet; //UIModalPresentationPageSheet;
    }
    [self.navigationController presentModalViewController:nv animated:YES];
}

// actionSheet ハンドラ
- (void)actionSheet:(UIActionSheet*)as clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (as == mAsActionButton) {
        mAsActionButton = nil;
        [self _actionActionButton:buttonIndex];
    }
    else if (as == mAsDelete) {
        mAsDelete = nil;
        [self _actionDelete:buttonIndex];
    }
    else {
        ASSERT(NO);
    }
}

#pragma mark BackupViewDelegate

- (void)backupViewFinished:(BackupViewController *)backupViewController
{
    [self reload];
    if (IS_IPAD) {
        mSplitTransactionListViewController.assetKey = -1;
        [mSplitTransactionListViewController reload];
    }
}

/*
- (IBAction)showHelp:(id)sender
{
    InfoVC *v = [[[InfoVC alloc] init] autorelease];
    //[self.navigationController pushViewController:v animated:YES];

    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:v];
    if (IS_IPAD) {
        nc.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    [self presentModalViewController:nc animated:YES];
    [nc release];
}
*/

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (IS_IPAD) return YES;
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
