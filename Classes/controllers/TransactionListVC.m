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
@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,readonly) Asset *asset;

@property (nonatomic) NSMutableArray *searchResults;

- (IBAction)showReport:(id)sender;
- (IBAction)doAction:(id)sender;

@end

@implementation TransactionListViewController
{
    IBOutlet UITableView *_tableView;
    IBOutlet UIBarButtonItem *_barBalanceLabel;
    IBOutlet UIBarButtonItem *_barActionButton;
    IBOutlet UIToolbar *_toolbar;
    
    int _assetKey;
    int _tappedIndex;
    
#if FREE_VERSION
    AdManager *_adManager;
    BOOL _isAdShowing;
#endif
    
    UIActionSheet *_actionSheet;
    UIPopoverController *_popoverController;
}

+ (TransactionListViewController *)instantiate
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"TransactionListView" bundle:nil];
    return [sb instantiateInitialViewController];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _assetKey = -1;
    }
    return self;
}

- (Asset *)asset
{
    if (_assetKey < 0) {
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
    return  [[[DataModel instance] ledger] assetWithKey:_assetKey];
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
	
    // Notifiction 受け取り手続き
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(willEnterForeground) name:@"willEnterForeground" object:nil];
    [nc addObserver:self selector:@selector(willResignActive) name:@"willResignActive" object:nil];
    
#if FREE_VERSION
    _isAdShowing = NO;
    _adManager = [AdManager sharedInstance];
    [_adManager attach:self rootViewController:self];
#endif
}

- (void)viewDidUnload
{
    NSLog(@"TransactionListViewController:viewDidUnload");
    [super viewDidUnload];

#if FREE_VERSION
    [_adManager detach];
#endif
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
    
#if FREE_VERSION
    [_adManager detach];
#endif
    
}

- (void)reload
{
    self.title = self.asset.name;
    [self updateBalance];
    [self.tableView reloadData];
    
    // 検索中
    if (self.searchDisplayController.isActive) {
        [self updateSearchResultWithDesc:self.searchDisplayController.searchBar.text];
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
    
    [self _dismissPopover];
}    

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    _popoverController = nil;
}

- (void)_dismissPopover
{
    if (IS_IPAD
        && _popoverController != nil
        && [_popoverController isPopoverVisible]
        && _tableView != nil && _tableView.window != nil /* for crash problem */)
    {
        [_popoverController dismissPopoverAnimated:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reload];
    
    [[Database instance] updateModificationDate]; // TODO : ここでやるのは正しくないが、、、
    
#if FREE_VERSION
    // 表示開始
    [_adManager requestShowAd];
#endif
}

/**
 * アプリが background に入るときの処理
 */
- (void)willResignActive
{
    if (_actionSheet != nil) {
        [_actionSheet dismissWithClickedButtonIndex:0 animated:NO];
        _actionSheet = nil;
    }
    //[self _dismissPopover];  // TODO: 効かない、、、
}

/**
 * アプリが foreground になった時の処理。
 * これは AppDelegate の applicationWillEnterForeground から呼び出される。
 */
- (void)willEnterForeground
{
#if FREE_VERSION
    // 表示開始
    [_adManager requestShowAd];
#endif
}

#if FREE_VERSION

/**
 * 広告表示
 */
- (void)adManager:(AdManager *)adManager showAd:(DFPView *)adView adSize:(CGSize)adSize
{
    if (_isAdShowing) {
        NSLog(@"Ad is already showing!");
        return;
    }
    _isAdShowing = YES;
    
    CGRect frame = _tableView.bounds;
    
    // 広告の位置を画面外に設定
    CGRect aframe = frame;
    aframe.origin.x = (frame.size.width - adSize.width) / 2;
    aframe.origin.y = frame.size.height; // 画面外
    aframe.size = adSize;
    
    adView.frame = aframe;
    [self.view addSubview:adView];
    [self.view bringSubviewToFront:_toolbar];
    
    // 広告領域分だけ、tableView の下部をあける
    CGRect tframe = frame;
    tframe.origin.x = 0;
    tframe.origin.y = 0;
    tframe.size.height -= adSize.height;
    _tableView.frame = tframe;

    // 表示位置
    aframe = frame;
    aframe.origin.x = (frame.size.width - adSize.width) / 2;
    aframe.origin.y = frame.size.height - adSize.height;
    aframe.size = adSize;
    
    // 広告をアニメーション表示させる
    [UIView beginAnimations:@"ShowAd" context:NULL];
    adView.frame = aframe;
    [UIView commitAnimations];
}

/**
 * 広告を隠す
 */
- (void)adManager:(AdManager *)adManager removeAd:(UIView *)adView adSize:(CGSize)adSize
{
    if (!_isAdShowing) {
        NSLog(@"Ad is already removed!");
        return;
    }
    _isAdShowing = NO;
    
    CGRect frame = _tableView.bounds;
        
    // tableView のサイズをもとに戻す
    frame.origin.x = 0;
    frame.origin.y = 0;
    frame.size.height += adSize.height;
    _tableView.frame = frame;
    
    // 広告の位置
    CGRect aframe = frame;
    aframe.origin.x = (frame.size.width - adSize.width) / 2;
    aframe.origin.y = frame.size.height;
    aframe.size = adSize;
    
    // 広告をアニメーション表示させる
    [UIView beginAnimations:@"HideAd" context:NULL];
    adView.frame = aframe;
    [UIView commitAnimations];
    
    [adView removeFromSuperview];
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
	
    _barBalanceLabel.title = [NSString stringWithFormat:@"%@ %@", _L(@"Balance"), bstr];
    
    if (IS_IPAD) {
        [self.splitAssetListViewController reload];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self _dismissPopover];
}

#pragma mark TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.asset == nil) return 0;

    int n;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        n = [self.searchResults count];
    } else {
        n = [self.asset entryCount] + 1;
    }
    return n;
}

- (CGFloat)tableView:(UITableView *)tv heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _tableView.rowHeight;
}

// 指定セル位置に該当する entry Index を返す
- (int)entryIndexWithIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    int idx;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        idx = ([self.searchResults count] - 1) - indexPath.row;
    } else {
        idx = ([self.asset entryCount] - 1) - indexPath.row;
    }
    return idx;
}

// 指定セル位置の Entry を返す
- (AssetEntry *)entryWithIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    int idx = [self entryIndexWithIndexPath:indexPath tableView:tableView];

    if (idx < 0) {
        return nil;  // initial balance
    }
    AssetEntry *e;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        e = [self.searchResults objectAtIndex:idx];
    } else {
        e = [self.asset entryAt:idx];
    }
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
	
    AssetEntry *e;
    
    e = [self entryWithIndexPath:indexPath tableView:tv];
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
	
    int idx = [self entryIndexWithIndexPath:indexPath tableView:tv];
    if (idx == -1) {
        // initial balance cell
        CalculatorViewController *v = [CalculatorViewController instantiate];
        v.delegate = self;
        v.value = self.asset.initialBalance;

        UINavigationController *nv = [[UINavigationController alloc] initWithRootViewController:v];
        
        if (!IS_IPAD) {
            [self presentViewController:nv animated:YES completion:NULL];
        } else {
            [self _dismissPopover];
            _popoverController = [[UIPopoverController alloc] initWithContentViewController:nv];
            _popoverController.delegate = self;
            [_popoverController presentPopoverFromRect:[tv cellForRowAtIndexPath:indexPath].frame inView:tv
               permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    } else if (idx >= 0) {
        // transaction view を表示
        if (tv == self.searchDisplayController.searchResultsTableView) {
            AssetEntry *e = [self.searchResults objectAtIndex:idx];
            _tappedIndex = e.originalIndex;
        } else {
            _tappedIndex = idx;
        }
        
        [self performSegueWithIdentifier:@"show" sender:self];
    }
}

// 画面遷移
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"show"]) {
        TransactionViewController *vc = [segue destinationViewController];
        vc.asset = self.asset;
        [vc setTransactionIndex:_tappedIndex];
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
            
    _tappedIndex = -1;
    [self performSegueWithIdentifier:@"show" sender:self];
}

// Editボタン処理
- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    if (self.asset == nil) return;
    
    [super setEditing:editing animated:animated];
	
    // tableView に通知
    [_tableView setEditing:editing animated:animated];
	
    if (editing) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

// 編集スタイルを返す
- (UITableViewCellEditingStyle)tableView:(UITableView*)tv editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int entryIndex = [self entryIndexWithIndexPath:indexPath tableView:tv];
    if (entryIndex < 0) {
        return UITableViewCellEditingStyleNone;
    } 
    return UITableViewCellEditingStyleDelete;
}

// 削除処理
- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)style forRowAtIndexPath:(NSIndexPath*)indexPath
{
    int entryIndex = [self entryIndexWithIndexPath:indexPath tableView:tv];

    if (entryIndex < 0) {
        // initial balance cell : do not delete!
        return;
    }

    if (style == UITableViewCellEditingStyleDelete) {
        if (tv == self.searchDisplayController.searchResultsTableView) {
            AssetEntry *e = [self.searchResults objectAtIndex:entryIndex];
            [self.asset deleteEntryAt:e.originalIndex];
            
            // 検索結果一覧を更新する
            [self updateSearchResultWithDesc:self.searchDisplayController.searchBar.text];
        } else {
            [self.asset deleteEntryAt:entryIndex];
        }

        // 残高再計算
        [self updateBalance];
        
        [tv deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tv reloadData];
    }

    if (IS_IPAD) {
        [self.splitAssetListViewController reload];
    }
}

#pragma mark Show Report
- (void)showReport:(id)sender
{
    ReportViewController *reportVC = [ReportViewController instantiate];
    [reportVC setAsset:self.asset];

    UINavigationController *nv = [[UINavigationController alloc] initWithRootViewController:reportVC];
    if (IS_IPAD) {
        nv.modalPresentationStyle = UIModalPresentationPageSheet;
    }
    
    //[self.navigationController pushViewController:vc animated:YES];
    [self.navigationController presentViewController:nv animated:YES completion:NULL];
}

#pragma mark Action sheet handling

// action sheet
- (void)doAction:(id)sender
{
    if (_actionSheet != nil) return;
    
    _actionSheet =
        [[UIActionSheet alloc]
         initWithTitle:nil
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
        [_actionSheet showFromBarButtonItem:_barActionButton animated:YES];
    } else {
        [_actionSheet showInView:[self view]];
    }
}

- (void)actionSheet:(UIActionSheet*)as clickedButtonAtIndex:(NSInteger)buttonIndex
{
    BackupViewController *backupVC;
    
    UIViewController *vc;
    UIModalPresentationStyle modalPresentationStyle = UIModalPresentationFormSheet;
    
    _actionSheet = nil;
    
    UINavigationController *nv = nil;
    switch (buttonIndex) {
        case 0:
            nv = [ExportVC instantiate:nil];
            break;
        
        case 1:
            nv = [ExportVC instantiate:self.asset];
            break;
            
        case 2:
            nv = [[UIStoryboard storyboardWithName:@"BackupView" bundle:nil] instantiateInitialViewController];
            backupVC = (BackupViewController *)nv.topViewController;
            backupVC.delegate = self;
            break;
            
        case 3:
            nv = [[UIStoryboard storyboardWithName:@"ConfigView" bundle:nil] instantiateInitialViewController];
            break;
            
        case 4:
            nv = [InfoVC instantiate];
            break;
            
        default:
            return;
    }

    if (nv == nil) {
        nv = [[UINavigationController alloc] initWithRootViewController:vc];
    }
    if (IS_IPAD) {
        nv.modalPresentationStyle = modalPresentationStyle;
    }
    
    //[self.navigationController pushViewController:vc animated:YES];
    [self.navigationController presentViewController:nv animated:YES completion:NULL];
}

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

// Landscape -> Portrait への移行
- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc
{
    barButtonItem.title = _L(@"Assets");
    self.navigationItem.leftBarButtonItem = barButtonItem;
    
    // 初期残高の popover が表示されている場合、ここで消さないと２つの Popover controller
    // が競合してしまう。
    [self _dismissPopover];
    
    _popoverController = pc;
}


// Portrait -> Landscape への移行
// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    self.navigationItem.leftBarButtonItem = nil;
    [self _dismissPopover];
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

#pragma mark - UISearchDisplayController Delegate

// 検索文字列が入力された
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self updateSearchResultWithDesc:searchString];
    return YES;
}

#pragma mark - 検索処理

- (void)updateSearchResultWithDesc:(NSString *)searchString
{
    BOOL allMatch = FALSE;
    if (searchString == nil || searchString.length == 0) {
        allMatch = TRUE;
    }

    int count = [self.asset entryCount];
    if (self.searchResults == nil) {
        self.searchResults = [[NSMutableArray alloc] initWithCapacity:count];
    } else {
        [self.searchResults removeAllObjects];
    }

    NSUInteger searchOptions = NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;

    for (int i = 0; i < count; i++) {
        AssetEntry *e = [self.asset entryAt:i];
        e.originalIndex = i;
        
        if (allMatch ) {
            [self.searchResults addObject:e];
            continue;
        }
        
        // 文字列マッチ
        NSString *desc = e.transaction.description;
        NSRange range = NSMakeRange(0, desc.length);
        NSRange foundRange = [desc rangeOfString:searchString options:searchOptions range:range];
        if (foundRange.length > 0) {
            [self.searchResults addObject:e];
        }
    }
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    self.searchResults = nil;
    
    // 検索中にデータが変更されるケースがあるので、ここで reload する
    [_tableView reloadData];
}

@end
