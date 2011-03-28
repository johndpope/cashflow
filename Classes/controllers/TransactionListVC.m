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

#if FREE_VERSION
#import "AdUtil.h"
#endif

@implementation TransactionListViewController

@synthesize tableView = mTableView;
@synthesize assetKey = mAssetKey;
@synthesize popoverController = mPopoverController;

- (id)init
{
    self = [super initWithNibName:@"TransactionListView" bundle:nil];
    return self;
}

- (Asset *)asset
{
    if (mAssetKey < 0) {
        return nil;
    }
    if (mAssetCache != nil && mAssetCache.pid == mAssetKey) {
        return mAssetCache;
    }
    mAssetCache = [[[DataModel instance] ledger] assetWithKey:mAssetKey];
    return mAssetCache;
}

- (void)viewDidLoad
{
    //NSLog(@"TransactionListViewController:viewDidLoad");

    [super viewDidLoad];
	
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
    [plusButton release];
	
    // Edit ボタンを追加
    // TBD
    //self.navigationItem.leftBarButtonItem = [self editButtonItem];
	
    mAsDisplaying = NO;
}

- (void)viewDidUnload
{
    //NSLog(@"TransactionListViewController:viewDidUnload");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [mTableView release];
    [mPopoverController release];
    
    [super dealloc];
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

#if FREE_VERSION
    if (mGADBannerView == nil) {
        [self _replaceAd];
    }
#endif
}

- (void)_replaceAd
{
#if FREE_VERSION
    
#if 0
    // Google Adsense バグ暫定対処
    // AdSense が起動時に正しく表示されずクラッシュする場合があるため、
    // 前回正しく表示できていない場合は初回表示させない
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int n = [defaults integerForKey:@"ShowAds"];
    if (n == 0) {
        [defaults setInteger:1 forKey:@"ShowAds"]; // show next time
        [defaults synchronize];
        return;
    }
    [defaults setInteger:0 forKey:@"ShowAds"];
    [defaults synchronize];
    
    if (mAdViewController != nil) {
        [mAdViewController.view removeFromSuperview];
        [mAdViewController release];
        mAdViewController = nil;
    }
#endif
    
    CGRect frame = mTableView.bounds;
    
    CGSize adSize;
    if (IS_IPAD) {
        adSize = GAD_SIZE_468x60;
        //adSize = GAD_SIZE_728x90;
    } else {
        adSize = GAD_SIZE_320x50;
    }
    
    // 画面下部固定で広告を作成する
    CGRect aframe = frame;
    aframe.origin.x = (frame.size.width - adSize.width) / 2;
    aframe.origin.y = frame.size.height - adSize.height;
    aframe.size = adSize;
    
    mGADBannerView = [[[GADBannerView alloc] initWithFrame:aframe] autorelease];
    
    mGADBannerView.adUnitID = ADMOB_PUBLISHER_ID;
    mGADBannerView.rootViewController = self;
    mGADBannerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    [self.view addSubview:mGADBannerView];

    GADRequest *req = [GADRequest request];
    //req.testing = YES;
    [mGADBannerView loadRequest:req];
    
    // 広告領域分だけ、tableView の下部をあける
    CGRect tframe = frame;
    tframe.size.height -= adSize.height;
    mTableView.frame = tframe;
#endif
}

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
        [mSplitAssetListViewController reload];
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
        CalculatorViewController *v = [[[CalculatorViewController alloc] init] autorelease];
        v.delegate = self;
        v.value = self.asset.initialBalance;

        UINavigationController *nv = [[[UINavigationController alloc] initWithRootViewController:v] autorelease];
        
        if (!IS_IPAD) {
            [self presentModalViewController:nv animated:YES];
        } else {
            if (self.popoverController) {
                [self.popoverController dismissPopoverAnimated:YES];
            }
            self.popoverController = [[[UIPopoverController alloc] initWithContentViewController:nv] autorelease];
            [self.popoverController presentPopoverFromRect:[tv cellForRowAtIndexPath:indexPath].frame inView:self.view
               permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    } else if (idx >= 0) {
        // transaction view を表示
        TransactionViewController *vc = [[[TransactionViewController alloc] init] autorelease];
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
    if (self.asset == nil) return;
    
    TransactionViewController *vc = [[[TransactionViewController alloc] init] autorelease];
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
	
        [tv deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self updateBalance];
        [mTableView reloadData];
    }

    if (IS_IPAD) {
        [mSplitAssetListViewController reload];
    }
}

#pragma mark Show Report
- (void)showReport:(id)sender
{
    ReportViewController *reportVC = [[[ReportViewController alloc] initWithAsset:self.asset] autorelease];

    UINavigationController *nv = [[UINavigationController alloc] initWithRootViewController:reportVC];
    if (IS_IPAD) {
        nv.modalPresentationStyle = UIModalPresentationPageSheet;
    }
    
    //[self.navigationController pushViewController:vc animated:YES];
    [self.navigationController presentModalViewController:nv animated:YES];
    [nv release];
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
         _L(@"Export"),
         [NSString stringWithFormat:@"%@ / %@", _L(@"Backup"), _L(@"Restore")],
         _L(@"Config"),
         _L(@"Info"),
         nil];
    if (IS_IPAD) {
        [as showFromBarButtonItem:mBarActionButton animated:YES];
    } else {
        [as showInView:[self view]];
    }
    [as release];
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
            exportVC = [[[ExportVC alloc] initWithAsset:self.asset] autorelease];
            vc = exportVC;
            break;
            
        case 1:
            backupVC = [BackupViewController backupViewController:self];
            vc = backupVC;
            break;
            
        case 2:
            configVC = [[[ConfigViewController alloc] init] autorelease];
            vc = configVC;
            break;
            
        case 3:
            infoVC = [[[InfoVC alloc] init] autorelease];
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
    [nv release];
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

#pragma mark BackupViewDelegate

- (void)backupViewFinished:(BackupViewController *)backupViewController
{
    // リストアされた場合、mAssetCacheは無効になっている
    mAssetCache = nil;
    
    if (IS_IPAD) {
        [self reload];
        [mSplitAssetListViewController reload];
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

@end
