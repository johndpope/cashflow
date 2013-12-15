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

@implementation AssetListViewController
{
    IBOutlet UITableView *_tableView;
    IBOutlet UIBarButtonItem *_barActionButton;
    IBOutlet UIBarButtonItem *_barSumLabel;
    
    BOOL _isLoadDone;
    DBLoadingView *_loadingView;
    
    Ledger *_ledger;

    NSMutableArray *_iconArray;

    BOOL _asDisplaying;
    UIActionSheet *_asActionButton;
    UIActionSheet *_asDelete;

    Asset *_assetToBeDelete;
    
    BOOL _pinChecked;
}

- (void)viewDidLoad
{
    NSLog(@"AssetListViewController:viewDidLoad");
    [super viewDidLoad];
    
    //[AppDelegate trackPageview:@"/AssetListViewController"];
     
    _tableView.rowHeight = 48;
    _pinChecked = NO;
    _asDisplaying = NO;
    
    _ledger = nil;
	
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
    _iconArray = [NSMutableArray new];
    int n = [Asset numAssetTypes];

    for (int i = 0; i < n; i++) {
        NSString *iconName = [Asset iconNameWithType:i];
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:iconName ofType:@"png"];
        UIImage *icon = [UIImage imageWithContentsOfFile:imagePath];
        ASSERT(icon != nil);
        [_iconArray addObject:icon];
    }

    if (IS_IPAD) {
        CGSize s = self.contentSizeForViewInPopover;
        s.height = 600;
        self.contentSizeForViewInPopover = s;
    }
    
    // データロード開始
    DataModel *dm = [DataModel instance];
    _isLoadDone = dm.isLoadDone;
    if (!_isLoadDone) {
        [dm startLoad:self];
    
        // Loading View を表示させる
        _loadingView = [[DBLoadingView alloc] initWithTitle:@"Loading"];
        [_loadingView setOrientation:self.interfaceOrientation];
        _loadingView.userInteractionEnabled = YES; // 下の View の操作不可にする
        [_loadingView show:self.view.window];
    }
}

- (void)viewDidUnload {
    NSLog(@"AssetLivewViewController:viewDidUnload");
    _iconArray = nil;

    _tableView = nil;
    _barActionButton = nil;
    _barSumLabel = nil;
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

    _isLoadDone = YES;
    _ledger = [DataModel ledger];
    
    [self performSelectorOnMainThread:@selector(_dataModelLoadedOnMainThread:) withObject:nil waitUntilDone:NO];
}

- (void)_dataModelLoadedOnMainThread:(id)dummy
{
    // dismiss loading view
    [_loadingView dismissAnimated:NO];
    _loadingView = nil;

    [self reload];
 
   /*
      '12/3/15
      安定性向上のため、iPad 以外では最後に使った資産に遷移しないようにした。
      起動時に TransactionListVC で固まるケースが多いため。
    
      '12/8/12 一旦元に戻す。
    */
    //if (IS_IPAD) {
        [self _showInitialAsset];
    //}
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
    Asset *asset = nil;
    
    // 前回選択資産を選択
    int firstShowAssetIndex = [self _firstShowAssetIndex];
    if (firstShowAssetIndex >= 0 && [_ledger assetCount] > firstShowAssetIndex) {
        asset = [_ledger assetAtIndex:firstShowAssetIndex];
    }
    // iPad では、前回選択資産がなくても、最初の資産を選択する
    if (IS_IPAD && asset == nil && [_ledger assetCount] > 0) {
        asset = [_ledger assetAtIndex:0];
    }

    // TransactionListView を表示
    if (asset != nil) {
        if (IS_IPAD) {
            self.splitTransactionListViewController.assetKey = asset.pid;
            [self.splitTransactionListViewController reload];
        } else { 
            TransactionListViewController *vc = 
                [TransactionListViewController instantiate];
            vc.assetKey = asset.pid;
            [self.navigationController pushViewController:vc animated:NO];
        }
    }

    // 資産が一個もない場合は警告を出す
    if ([_ledger assetCount] == 0) {
        [AssetListViewController noAssetAlert];
    }
}

+ (void)noAssetAlert
{
    UIAlertView *v = [[UIAlertView alloc]
                      initWithTitle:@"No assets"
                      message:_L(@"At first, please create and select an asset.")
                      delegate:nil
                      cancelButtonTitle:_L(@"Dismiss")
                      otherButtonTitles:nil];
    [v show];
}

- (void)reload
{
    if (!_isLoadDone) return;
    
    _ledger = [DataModel ledger];
    [_ledger rebuild];
    [_tableView reloadData];

    // 合計欄
    double value = 0.0;
    for (int i = 0; i < [_ledger assetCount]; i++) {
        value += [[_ledger assetAtIndex:i] lastBalance];
    }
    NSString *lbl = [NSString stringWithFormat:@"%@ %@", _L(@"Total"), [CurrencyManager formatCurrency:value]];
    _barSumLabel.title = lbl;
    
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
    if (!_isLoadDone) return 0;
    
    return [_ledger assetCount];
}

- (int)_assetIndex:(NSIndexPath*)indexPath
{
    return indexPath.row;
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellid];
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
        cell.textLabel.font = [UIFont systemFontOfSize:16.0];
    }

    // 資産
    Asset *asset = [_ledger assetAtIndex:[self _assetIndex:indexPath]];

    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;

    // 資産タイプ範囲外対応
    int type = asset.type;
    if (type < 0 || [_iconArray count] <= type) {
        type = 0;
    }
    cell.imageView.image = _iconArray[type];

    // 資産名
    cell.textLabel.text = asset.name;

    // 残高
    double value = [asset lastBalance];
    NSString *c = [CurrencyManager formatCurrency:value];
    cell.detailTextLabel.text = c;
    
    if (value >= 0) {
        cell.detailTextLabel.textColor = [UIColor blueColor];
    } else {
        cell.detailTextLabel.textColor = [UIColor redColor];
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
	
    Asset *asset = [_ledger assetAtIndex:assetIndex];

    // TransactionListView を表示
    if (IS_IPAD) {
        self.splitTransactionListViewController.assetKey = asset.pid;
        [self.splitTransactionListViewController reload];
    } else {
        TransactionListViewController *vc = 
            [TransactionListViewController instantiate];
        vc.assetKey = asset.pid;

        [self.navigationController pushViewController:vc animated:YES];
    }
}

// アクセサリボタンをタップしたときの処理 : アセット変更
- (void)tableView:(UITableView *)tv accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    AssetViewController *vc = [AssetViewController new];
    int assetIndex = [self _assetIndex:indexPath];
    if (assetIndex >= 0) {
        [vc setAssetIndex:indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

// 新規アセット追加
- (void)addAsset
{
    AssetViewController *vc = [AssetViewController new];
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
        _assetToBeDelete = [_ledger assetAtIndex:assetIndex];

        _asDelete =
            [[UIActionSheet alloc]
                initWithTitle:_L(@"ReallyDeleteAsset")
                delegate:self
                cancelButtonTitle:@"Cancel"
                destructiveButtonTitle:_L(@"Delete Asset")
                otherButtonTitles:nil];
        _asDelete.actionSheetStyle = UIActionSheetStyleDefault;
        
        // 注意: self.view から showInView すると、iPad縦画面でクラッシュする。self.view.window にすれば OK。
        [_asDelete showInView:self.view.window];
    }
}

- (void)_actionDelete:(NSInteger)buttonIndex
{
    if (buttonIndex != 0) {
        return; // cancelled;
    }
	
    int pid = _assetToBeDelete.pid;
    [_ledger deleteAsset:_assetToBeDelete];
    
    if (IS_IPAD) {
        if (self.splitTransactionListViewController.assetKey == pid) {
            self.splitTransactionListViewController.assetKey = -1;
            [self.splitTransactionListViewController reload];
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
    if (_asDisplaying) return;
    _asDisplaying = YES;
    
    _asActionButton = 
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

    //if (IS_IPAD) {
    //    [mAsActionButton showFromBarButtonItem:mBarActionButton animated:YES];
    //}
    
    [_asActionButton showInView:[self view]];
}

- (void)_actionActionButton:(NSInteger)buttonIndex
{
    ExportVC *exportVC;
    ConfigViewController *configVC;
    InfoVC *infoVC;
    BackupViewController *backupVC;
    UIViewController *vc;
    
    _asDisplaying = NO;
    
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
            configVC = [ConfigViewController new];
            vc = configVC;
            break;
            
        case 3:
            infoVC = [InfoVC new];
            vc = infoVC;
            break;
            
        default:
            return;
    }
    
    UINavigationController *nv = [[UINavigationController alloc] initWithRootViewController:vc];
    //if (IS_IPAD) {
    //    nv.modalPresentationStyle = UIModalPresentationFormSheet; //UIModalPresentationPageSheet;
    //}
    [self.navigationController presentModalViewController:nv animated:YES];
}

// actionSheet ハンドラ
- (void)actionSheet:(UIActionSheet*)as clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (as == _asActionButton) {
        _asActionButton = nil;
        [self _actionActionButton:buttonIndex];
    }
    else if (as == _asDelete) {
        _asDelete = nil;
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
        self.splitTransactionListViewController.assetKey = -1;
        [self.splitTransactionListViewController reload];
    }
}

/*
- (IBAction)showHelp:(id)sender
{
    InfoVC *v = [InfoVC new];
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

// iOS 6 later
- (NSUInteger)supportedInterfaceOrientations
{
    if (IS_IPAD) return UIInterfaceOrientationMaskAll;
    if (IS_IPAD) return UIInterfaceOrientationPortrait;
    return UIInterfaceOrientationPortrait;
}
- (BOOL)shouldAutorotate
{
    if (IS_IPAD) return YES;
    return NO;
}

@end
