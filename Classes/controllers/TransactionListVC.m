// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "TransactionListVC.h"
#import "TransactionCell.h"
#import "AppDelegate.h"
#import "Transaction.h"
#import "InfoVC.h"
#import "CalcVC.h"
#import "ReportVC.h"
#import "ConfigViewController.h"
#import "AssetListVC.h"
#import "BackupVC.h"
#import "Database.h"

@interface TransactionListViewController ()
- (IBAction)showReport:(id)sender;
- (IBAction)doAction:(id)sender;
//- (IBAction)showHelp:(id)sender;
@end

@implementation TransactionListViewController
{
    IBOutlet UITableView *mTableView;
    IBOutlet UIBarButtonItem *mBarBalanceLabel;
    IBOutlet UIBarButtonItem *mBarActionButton;
    IBOutlet UIToolbar *mToolbar;
    
    int mAssetKey;
    //Asset *mAssetCache;
    
#if FREE_VERSION
    AdManager *mAdManager;
#endif
    
    BOOL mAsDisplaying;
    UIPopoverController *mPopoverController;
}

@synthesize tableView = mTableView;
@synthesize assetKey = mAssetKey;
@synthesize popoverController = mPopoverController;

- (id)init
{
    self = [super initWithNibName:@"TransactionListView" bundle:nil];
    if (self) {
        mAssetKey = -1;
    }
    return self;
}

- (Asset *)asset
{
    if (mAssetKey < 0) {
        return nil;
    }
    
#if 0
    // 安全のため、cache を使わないようにした
    if (mAssetCache != nil && mAssetCache.pid == mAssetKey) {
        return mAssetCache;
    }
    mAssetCache = [[[DataModel instance] ledger] assetWithKey:mAssetKey];
    return mAssetCache;
#endif
    return  [[[DataModel instance] ledger] assetWithKey:mAssetKey];
}

- (void)viewDidLoad
{
    NSLog(@"TransactionListViewController:viewDidLoad");

    [super viewDidLoad];
    
    //[AppDelegate trackPageview:@"/TransactionListViewController"];
	
    // title 設定
    //self.title = _L(@"Transactions");
    if (self.asset == nil) {
        self.title = @"";
    } else {
        self.title = self.asset.name;
    }
	
    // "+" ボタンを追加
    UIBarButtonItem *plusButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                      target:self
                                      action:@selector(addTransaction)];
	
    self.navigationItem.rightBarButtonItem = plusButton;
	
    // Edit ボタンを追加
    // TBD
    //self.navigationItem.leftBarButtonItem = [self editButtonItem];
	
    mAsDisplaying = NO;

#if FREE_VERSION
    static NSTimeInterval adDisableTime = 0;
    
    NSTimeInterval current = [NSDate timeIntervalSinceReferenceDate];
    
    if ([AppDelegate isPrevCrashed] && (adDisableTime == 0 || current - adDisableTime < 60 * 60)) {
        // 前回クラッシュしていた場合は、一定時間広告を出さない
        adDisableTime = current;
        return;
    }
        
    mAdManager = [AdManager sharedInstance];
    [mAdManager attach:self rootViewController:self];
#endif
}

- (void)viewDidUnload
{
    NSLog(@"TransactionListViewController:viewDidUnload");
    [super viewDidUnload];

#if FREE_VERSION
    [mAdManager detach];
#endif
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    
#if FREE_VERSION
    [mAdManager detach];
#endif
    
}

- (void)reload
{
    self.title = self.asset.name;
    [self updateBalance];
    [self.tableView reloadData];

    if (mPopoverController != nil && [mPopoverController isPopoverVisible]) {
        [mPopoverController dismissPopoverAnimated:YES];
    }
}    

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reload];
    
    [[Database instance] updateModificationDate]; // TODO : ここでやるのは正しくないが、、、
    
#if FREE_VERSION
    // 表示開始
    [mAdManager showAd];
#endif
}

#if FREE_VERSION
/**
 * 広告セット(まだ表示はしない)
 */
- (void)adManager:(AdManager *)adManager setAd:(UIView *)adView adSize:(CGSize)adSize
{
    CGRect frame = mTableView.bounds;

    // 広告の位置を画面外に設定
    CGRect aframe = frame;
    aframe.origin.x = (frame.size.width - adSize.width) / 2;
    aframe.origin.y = frame.size.height; // 画面外
    aframe.size = adSize;
    
    adView.frame = aframe;
    adView.hidden = YES;
    [self.view addSubview:adView];
    [self.view bringSubviewToFront:mToolbar];
}

/**
 * 広告表示
 */
- (void)adManager:(AdManager *)adManager showAd:(UIView *)adView adSize:(CGSize)adSize
{
    CGRect frame = mTableView.bounds;

    // 広告領域分だけ、tableView の下部をあける
    CGRect tframe = frame;
    tframe.origin.x = 0;
    tframe.origin.y = 0;
    tframe.size.height -= adSize.height;
    mTableView.frame = tframe;

    // 広告の位置
    CGRect aframe = frame;
    aframe.origin.x = (frame.size.width - adSize.width) / 2;
    aframe.origin.y = frame.size.height - adSize.height;
    aframe.size = adSize;
    
    // 広告をアニメーション表示させる
    adView.hidden = NO;
    [UIView beginAnimations:@"ShowAd" context:NULL];
    adView.frame = aframe;
    [UIView commitAnimations];
}

/**
 * 広告を隠す
 */
- (void)adManager:(AdManager *)adManager hideAd:(UIView *)adView adSize:(CGSize)adSize
{
    adView.hidden = YES;
    
    CGRect frame = mTableView.bounds;
        
    // tableView のサイズをもとに戻す
    frame.origin.x = 0;
    frame.origin.y = 0;
    frame.size.height += adSize.height;
    mTableView.frame = frame;
    
    // 広告の位置
    CGRect aframe = frame;
    aframe.origin.x = (frame.size.width - adSize.width) / 2;
    aframe.origin.y = frame.size.height;
    aframe.size = adSize;
    
    // 広告をアニメーション表示させる
    adView.hidden = NO;
    [UIView beginAnimations:@"HideAd" context:NULL];
    adView.frame = aframe;
    [UIView commitAnimations];
    adView.hidden = YES;
}

#endif

- (void)viewDidAppear:(BOOL)animated
{
    //NSLog(@"TransactionListViewController:viewDidAppear");

    [super viewDidAppear:animated];
}

- (void)updateBalance
{
    double lastBalance = [self.asset lastBalance];
    NSString *bstr = [CurrencyManager formatCurrency:lastBalance];

#if 0
    UILabel *tableTitle = (UILabel *)[self.tableView tableHeaderView];
    tableTitle.text = [NSString stringWithFormat:@"%@ %@", _L(@"Balance"), bstr];
#endif
	
    mBarBalanceLabel.title = [NSString stringWithFormat:@"%@ %@", _L(@"Balance"), bstr];
    
    if (IS_IPAD) {
        [self.splitAssetListViewController reload];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
}

- (void)viewDidDisappear:(BOOL)animated {
}

#pragma mark TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.asset == nil) return 0;
    
    int n = [self.asset entryCount] + 1;
    return n;
}

- (CGFloat)tableView:(UITableView *)tv heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return mTableView.rowHeight;
}

// 指定セル位置に該当する entry Index を返す
- (int)entryIndexWithIndexPath:(NSIndexPath *)indexPath
{
    int idx = ([self.asset entryCount] - 1) - indexPath.row;
    return idx;
}

// 指定セル位置の Entry を返す
- (AssetEntry *)entryWithIndexPath:(NSIndexPath *)indexPath
{
    int idx = [self entryIndexWithIndexPath:indexPath];

    if (idx < 0) {
        return nil;  // initial balance
    } 
    AssetEntry *e = [self.asset entryAt:idx];
    return e;
}

//
// セルの内容を返す
//
#define TAG_DESC 1
#define TAG_DATE 2
#define TAG_VALUE 3
#define TAG_BALANCE 4

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TransactionCell *cell;
	
    AssetEntry *e = [self entryWithIndexPath:indexPath];
    if (e) {
        cell = [[TransactionCell transactionCell:tv] updateWithAssetEntry:e];
    }
    else {
        cell = [[TransactionCell transactionCell:tv] updateAsInitialBalance:self.asset.initialBalance];
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
	
    int idx = [self entryIndexWithIndexPath:indexPath];
    if (idx == -1) {
        // initial balance cell
        CalculatorViewController *v = [CalculatorViewController new];
        v.delegate = self;
        v.value = self.asset.initialBalance;

        UINavigationController *nv = [[UINavigationController alloc] initWithRootViewController:v];
        
        if (!IS_IPAD) {
            [self presentModalViewController:nv animated:YES];
        } else {
            if (self.popoverController) {
                [self.popoverController dismissPopoverAnimated:YES];
            }
            self.popoverController = [[UIPopoverController alloc] initWithContentViewController:nv];
            [self.popoverController presentPopoverFromRect:[tv cellForRowAtIndexPath:indexPath].frame inView:tv
               permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    } else if (idx >= 0) {
        // transaction view を表示
        TransactionViewController *vc = [TransactionViewController new];
        vc.asset = self.asset;
        [vc setTransactionIndex:idx];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

// 初期残高変更処理
- (void)calculatorViewChanged:(CalculatorViewController *)vc
{
    self.asset.initialBalance = vc.value;
    [self.asset updateInitialBalance];
    [self.asset rebuild];
    [self reload];
}

// 新規トランザクション追加
- (void)addTransaction
{
    if (self.asset == nil) {
        [AssetListViewController noAssetAlert];
        return;
    }
    
    TransactionViewController *vc = [TransactionViewController new];
    vc.asset = self.asset;
    [vc setTransactionIndex:-1];
    [self.navigationController pushViewController:vc animated:YES];
}

// Editボタン処理
- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    if (self.asset == nil) return;
    
    [super setEditing:editing animated:animated];
	
    // tableView に通知
    [mTableView setEditing:editing animated:animated];
	
    if (editing) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

// 編集スタイルを返す
- (UITableViewCellEditingStyle)tableView:(UITableView*)tv editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int entryIndex = [self entryIndexWithIndexPath:indexPath];
    if (entryIndex < 0) {
        return UITableViewCellEditingStyleNone;
    } 
    return UITableViewCellEditingStyleDelete;
}

// 削除処理
- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)style forRowAtIndexPath:(NSIndexPath*)indexPath
{
    int entryIndex = [self entryIndexWithIndexPath:indexPath];

    if (entryIndex < 0) {
        // initial balance cell : do not delete!
        return;
    }
	
    if (style == UITableViewCellEditingStyleDelete) {
        [self.asset deleteEntryAt:entryIndex];
	
        [tv deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self updateBalance];
        [mTableView reloadData];
    }

    if (IS_IPAD) {
        [self.splitAssetListViewController reload];
    }
}

#pragma mark Show Report
- (void)showReport:(id)sender
{
    ReportViewController *reportVC = [[ReportViewController alloc] initWithAsset:self.asset];

    UINavigationController *nv = [[UINavigationController alloc] initWithRootViewController:reportVC];
    if (IS_IPAD) {
        nv.modalPresentationStyle = UIModalPresentationPageSheet;
    }
    
    //[self.navigationController pushViewController:vc animated:YES];
    [self.navigationController presentModalViewController:nv animated:YES];
}

#pragma mark Action sheet handling

// action sheet
- (void)doAction:(id)sender
{
    if (mAsDisplaying) return;
    mAsDisplaying = YES;
    
    UIActionSheet *as = 
        [[UIActionSheet alloc]
         initWithTitle:@"" 
         delegate:self 
         cancelButtonTitle:_L(@"Cancel")
         destructiveButtonTitle:nil otherButtonTitles:
         [NSString stringWithFormat:@"%@ (%@)", _L(@"Export"), _L(@"All assets")],
         [NSString stringWithFormat:@"%@ (%@)", _L(@"Export"), _L(@"This asset")],
         [NSString stringWithFormat:@"%@ / %@", _L(@"Sync"), _L(@"Backup")],
         _L(@"Config"),
         _L(@"Info"),
         nil];
    if (IS_IPAD) {
        [as showFromBarButtonItem:mBarActionButton animated:YES];
    } else {
        [as showInView:[self view]];
    }
}

- (void)actionSheet:(UIActionSheet*)as clickedButtonAtIndex:(NSInteger)buttonIndex
{
    ExportVC *exportVC;
    ConfigViewController *configVC;
    InfoVC *infoVC;
    BackupViewController *backupVC;
    
    UIViewController *vc;
    UIModalPresentationStyle modalPresentationStyle = UIModalPresentationFormSheet;
    
    mAsDisplaying = NO;
    
    switch (buttonIndex) {
        case 0:
            exportVC = [[ExportVC alloc] initWithAsset:nil];
            vc = exportVC;
            break;
        
        case 1:
            exportVC = [[ExportVC alloc] initWithAsset:self.asset];
            vc = exportVC;
            break;
            
        case 2:
            backupVC = [BackupViewController backupViewController:self];
            vc = backupVC;
            break;
            
        case 3:
            configVC = [ConfigViewController new];
            vc = configVC;
            break;
            
        case 4:
            infoVC = [InfoVC new];
            vc = infoVC;
            break;
            
        default:
            return;
    }

    UINavigationController *nv = [[UINavigationController alloc] initWithRootViewController:vc];
    if (IS_IPAD) {
        nv.modalPresentationStyle = modalPresentationStyle;
    }
    
    //[self.navigationController pushViewController:vc animated:YES];
    [self.navigationController presentModalViewController:nv animated:YES];
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

#pragma mark BackupViewDelegate

- (void)backupViewFinished:(BackupViewController *)backupViewController
{
    // リストアされた場合、mAssetCacheは無効になっている
    //mAssetCache = nil;
    
    if (IS_IPAD) {
        [self reload];
        [self.splitAssetListViewController reload];
    }
}

#pragma mark Split View Delegate

- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc
{
    barButtonItem.title = _L(@"Assets");
    self.navigationItem.leftBarButtonItem = barButtonItem;
    self.popoverController = pc;
}


// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    self.navigationItem.leftBarButtonItem = nil;
    self.popoverController = nil;
}

#pragma mark Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (IS_IPAD) return YES;
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
// iOS 6 later
- (NSUInteger)supportedInterfaceOrientations
{
    if (IS_IPAD) return UIInterfaceOrientationMaskAll;
    return UIInterfaceOrientationPortrait;
}
- (BOOL)shouldAutorotate
{
    if (IS_IPAD) return YES;
    return NO;
}

@end
