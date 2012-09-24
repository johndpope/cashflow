// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "TransactionVC.h"
#import "AppDelegate.h"
#import "Config.h"
#import "CalendarViewController.h"

// private methods
@interface TransactionViewController()
- (void)_asDelPast:(int)buttonIndex;
- (void)_asCancelTransaction:(int)buttonIndex;

- (UITableViewCell *)getCellForField:(NSIndexPath*)indexPath tableView:(UITableView *)tableView;
- (void)_dismissPopover;

- (void)checkLastUsedDate:(NSDate *)date;
@end

@implementation TransactionViewController
{
    int mTransactionIndex;
    AssetEntry *mEditingEntry;
    Asset *__unsafe_unretained mAsset;

    BOOL mIsModified;

    NSArray *mTypeArray;
	
    UIButton *mDelButton;
    UIButton *mDelPastButton;

    UIActionSheet *mAsDelPast;
    UIActionSheet *mAsCancelTransaction;
    
    UIPopoverController *mCurrentPopoverController;
}

@synthesize editingEntry = mEditingEntry;
@synthesize asset = mAsset;

#define ROW_DATE  0
#define ROW_TYPE  1
#define ROW_VALUE 2
#define ROW_DESC  3
#define ROW_CATEGORY 4
#define ROW_MEMO  5

#define NUM_ROWS 6

// for debug
#define REFCOUNT(x) CFGetRetainCount((__bridge void *)(x))

- (id)init
{
    self = [super initWithNibName:@"TransactionView" bundle:nil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //[AppDelegate trackPageview:@"/TransactionViewController"];
    
    mIsModified = NO;

    self.title = _L(@"Transaction");
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                  initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                  target:self
                                                  action:@selector(saveAction)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                                  initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                  target:self
                                                  action:@selector(cancelAction)];

    mTypeArray = @[_L(@"Payment"),
                                 _L(@"Deposit"),
                                 _L(@"Adjustment"),
                                 _L(@"Transfer")];

    // ボタン生成
    // TODO:
    // b を unsafe unretained にしておかないと、オブジェクトのリファレンスカウンタが足りなくなりクラッシュする。
    // ARC 周りのバグか？
    __unsafe_unretained UIButton *b;
    UIImage *bg = [[UIImage imageNamed:@"redButton.png"] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0];

    int i;
    for (i = 0; i < 2; i++) {
        b = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [b setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [b setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
        b.titleLabel.font = [UIFont systemFontOfSize:14.0];
	
        [b setBackgroundImage:bg forState:UIControlStateNormal];
		
        const int width = 300;
        const int height = 40;
        CGRect rect = CGRectMake((self.view.frame.size.width - width) / 2.0, 310, width, height);
        if (IS_IPAD) {
            rect.origin.y += 100; // ad hoc...
        }
        
        if (i == 0) {
            [b setFrame:rect];
            [b setTitle:_L(@"Delete transaction") forState:UIControlStateNormal];
            [b addTarget:self action:@selector(delButtonTapped) forControlEvents:UIControlEventTouchUpInside];
            mDelButton = b;
        } else {
            rect.origin.y += 55;
            [b setFrame:rect];
            [b setTitle:_L(@"Delete with all past transactions") forState:UIControlStateNormal];
            [b addTarget:self action:@selector(delPastButtonTapped) forControlEvents:UIControlEventTouchUpInside];
            mDelPastButton = b;
        }

        b.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self.view addSubview:b];
        b = nil; // 念のため
    }
}

// 処理するトランザクションをロードしておく
- (void)setTransactionIndex:(int)n
{
    mTransactionIndex = n;

    self.editingEntry = nil;

    if (mTransactionIndex < 0) {
        // 新規トランザクション
        self.editingEntry = [[AssetEntry alloc] initWithTransaction:nil withAsset:mAsset];
    } else {
        // 変更
        AssetEntry *orig = [mAsset entryAt:mTransactionIndex];
        self.editingEntry = [orig copy];
    }
}

// 表示前の処理
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    BOOL hideDelButton = (mTransactionIndex >= 0) ? NO : YES;
	
    mDelButton.hidden = hideDelButton;
    mDelPastButton.hidden = hideDelButton;
		
    [[self tableView] reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //[[self tableView] reloadData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    /*
    [mDelButton removeFromSuperview];
    mDelButton = nil;
    [mDelPastButton removeFromSuperview];
    mDelPastButton = nil;
    */
}

/////////////////////////////////////////////////////////////////////////////////
// TableView 表示処理

#pragma mark UITableViewDataSource

// セクション数
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

// 行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    return NUM_ROWS;
}

// 行の内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    return [self getCellForField:indexPath tableView:tableView];
}

- (UITableViewCell *)getCellForField:(NSIndexPath*)indexPath tableView:(UITableView *)tableView
{
    static NSString *MyIdentifier = @"transactionViewCells";
    UILabel *name, *value;

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:MyIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    name = cell.textLabel;
    value = cell.detailTextLabel;

    double evalue;
    switch (indexPath.row) {
    case ROW_DATE:
        name.text = _L(@"Date");
        value.text = [[DataModel dateFormatter] stringFromDate:mEditingEntry.transaction.date];
        break;

    case ROW_TYPE:
        name.text = _L(@"Type"); // @"Transaction type"
        value.text = mTypeArray[mEditingEntry.transaction.type];
        break;
		
    case ROW_VALUE:
        name.text = _L(@"Amount");
        evalue = mEditingEntry.evalue;
        value.text = [CurrencyManager formatCurrency:evalue];
        break;
		
    case ROW_DESC:
        name.text = _L(@"Name");
        value.text = mEditingEntry.transaction.description;
        break;
			
    case ROW_CATEGORY:
        name.text = _L(@"Category");
        value.text = [[DataModel categories] categoryStringWithKey:mEditingEntry.transaction.category];
        break;
			
    case ROW_MEMO:
        name.text = _L(@"Memo");
        value.text = mEditingEntry.transaction.memo;
        break;
    }

    return cell;
}

///////////////////////////////////////////////////////////////////////////////////
// 値変更処理

#pragma mark UITableViewDelegate

// セルをクリックしたときの処理
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UINavigationController *nc = self.navigationController;

    UIViewController *vc = nil;

    EditTypeViewController *editTypeVC; // type
    CalculatorViewController *calcVC;
    EditDescViewController *editDescVC;
    EditMemoViewController *editMemoVC; // memo
    CategoryListViewController *editCategoryVC;

    // view を表示

    switch (indexPath.row) {
        case ROW_DATE:
            if ([Config instance].dateTimeMode == DateTimeModeDateOnly) {
                CalendarViewController *calendarVc = [CalendarViewController new];
                calendarVc.selectedDate = mEditingEntry.transaction.date;
                [calendarVc setCalendarViewControllerDelegate:self];
                vc = calendarVc;
            } else {
                EditDateViewController *editDateVC = [[EditDateViewController alloc] init];
                editDateVC.delegate = self;
                editDateVC.date = mEditingEntry.transaction.date;
                vc = editDateVC;
            }
            break;

        case ROW_TYPE:
            editTypeVC = [[EditTypeViewController alloc] init];
            editTypeVC.delegate = self;
            editTypeVC.type = mEditingEntry.transaction.type;
            editTypeVC.dstAsset = [mEditingEntry dstAsset];
            vc = editTypeVC;
            break;

        case ROW_VALUE:
            calcVC = [[CalculatorViewController alloc] init];
            calcVC.delegate = self;
            calcVC.value = mEditingEntry.evalue;
            vc = calcVC;
            break;

        case ROW_DESC:
            editDescVC = [[EditDescViewController alloc] init];
            editDescVC.delegate = self;
            editDescVC.description = mEditingEntry.transaction.description;
            editDescVC.category = mEditingEntry.transaction.category;
            vc = editDescVC;
            break;

        case ROW_MEMO:
            editMemoVC = [EditMemoViewController
                          editMemoViewController:self
                          title:_L(@"Memo") 
                          identifier:0];
            editMemoVC.text = mEditingEntry.transaction.memo;
            vc = editMemoVC;
            break;

        case ROW_CATEGORY:
            editCategoryVC = [[CategoryListViewController alloc] init];
            editCategoryVC.isSelectMode = YES;
            editCategoryVC.delegate = self;
            editCategoryVC.selectedIndex = [[DataModel categories] categoryIndexWithKey:mEditingEntry.transaction.category];
            vc = editCategoryVC;
            break;
    }
            
    if (IS_IPAD) { // TBD
        nc = [[UINavigationController alloc] initWithRootViewController:vc];
        
        mCurrentPopoverController = [[UIPopoverController alloc] initWithContentViewController:nc];
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        CGRect rect = cell.frame;
        [mCurrentPopoverController presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else {
        [nc pushViewController:vc animated:YES];
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    if (IS_IPAD && mCurrentPopoverController != nil) {
        mCurrentPopoverController = nil;
    }
}

- (void)_dismissPopover
{
    if (IS_IPAD) {
        if (mCurrentPopoverController != nil) {
            [mCurrentPopoverController dismissPopoverAnimated:YES];
        }
        [self.tableView reloadData];
    }
}

#pragma mark EditView delegates

// delegate : 下位 ViewController からの変更通知

- (void)calendarViewController:(CalendarViewController *)aCalendarViewController dateDidChange:(NSDate *)aDate
{
    if (aDate == nil) return; // do nothing (Clear button)
    
    mIsModified = YES;
    mEditingEntry.transaction.date = aDate;
    [self checkLastUsedDate:aDate];

    if (IS_IPAD) {
        [self _dismissPopover];
    }
    // Si-Calendar は、選択時に自動で View を閉じない仕様なので、ここで閉じる
    [aCalendarViewController.navigationController popViewControllerAnimated:YES];
}

- (void)editDateViewChanged:(EditDateViewController *)vc
{
    mIsModified = YES;

    mEditingEntry.transaction.date = vc.date;
    [self checkLastUsedDate:vc.date];
    
    [self _dismissPopover];
}

// 入力した日付が現在時刻から離れている場合のみ、日付を記憶
- (void)checkLastUsedDate:(NSDate *)date
{
    NSTimeInterval diff = [[NSDate new] timeIntervalSinceDate:date];
    if (diff < 0.0) diff = -diff;
    if (diff > 24*60*60) {
        [Transaction setLastUsedDate:date];
    } else {
        [Transaction setLastUsedDate:nil];
    }
}

- (void)editTypeViewChanged:(EditTypeViewController*)vc
{
    mIsModified = YES;

    // autoPop == NO なので、自分で pop する
    [self.navigationController popToViewController:self animated:YES];

    if (![mEditingEntry changeType:vc.type assetKey:mAsset.pid dstAssetKey:vc.dstAsset]) {
        return;
    }

    switch (mEditingEntry.transaction.type) {
    case TYPE_ADJ:
        mEditingEntry.transaction.description = mTypeArray[mEditingEntry.transaction.type];
        break;

    case TYPE_TRANSFER:
        {
            Asset *from, *to;
            Ledger *ledger = [DataModel ledger];
            from = [ledger assetWithKey:mEditingEntry.transaction.asset];
            to = [ledger assetWithKey:mEditingEntry.transaction.dstAsset];

            mEditingEntry.transaction.description = 
                [NSString stringWithFormat:@"%@/%@", from.name, to.name];
        }
        break;

    default:
        break;
    }

    [self _dismissPopover];
}

- (void)calculatorViewChanged:(CalculatorViewController *)vc
{
    mIsModified = YES;

    [mEditingEntry setEvalue:vc.value];
    [self _dismissPopover];
}

- (void)editDescViewChanged:(EditDescViewController *)vc
{
    mIsModified = YES;

    mEditingEntry.transaction.description = vc.description;

    if (mEditingEntry.transaction.category < 0) {
        // set category from description
        mEditingEntry.transaction.category = [[DataModel instance] categoryWithDescription:mEditingEntry.transaction.description];
    }
    [self _dismissPopover];
}

- (void)editMemoViewChanged:(EditMemoViewController*)vc identifier:(int)id
{
    mIsModified = YES;

    mEditingEntry.transaction.memo = vc.text;
    [self _dismissPopover];
}

- (void)categoryListViewChanged:(CategoryListViewController*)vc;
{
    mIsModified = YES;

    if (vc.selectedIndex < 0) {
        mEditingEntry.transaction.category = -1;
    } else {
        TCategory *c = [[DataModel categories] categoryAtIndex:vc.selectedIndex];
        mEditingEntry.transaction.category = c.pid;
    }
    [self _dismissPopover];
}

////////////////////////////////////////////////////////////////////////////////
// 削除処理

#pragma mark Deletion

- (void)delButtonTapped
{
    [mAsset deleteEntryAt:mTransactionIndex];
    self.editingEntry = nil;
	
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)delPastButtonTapped
{
    mAsDelPast = [[UIActionSheet alloc]
                    initWithTitle:nil delegate:self
                    cancelButtonTitle:@"Cancel"
                    destructiveButtonTitle:_L(@"Delete with all past transactions")
                    otherButtonTitles:nil];
    mAsDelPast.actionSheetStyle = UIActionSheetStyleDefault;
    [mAsDelPast showInView:self.view];
}

- (void)_asDelPast:(NSInteger)buttonIndex
{
    if (buttonIndex != 0) {
         return; // cancelled;
    }

    AssetEntry *e = [mAsset entryAt:mTransactionIndex];
	
    NSDate *date = e.transaction.date;
    [mAsset deleteOldEntriesBefore:date];
	
    self.editingEntry = nil;
	
    [self.navigationController popViewControllerAnimated:YES];
}

////////////////////////////////////////////////////////////////////////////////
// 保存処理

#pragma mark Save action

- (void)saveAction
{
    //editingEntry.transaction.asset = asset.pkey;

    // upsert 処理
    if (mTransactionIndex < 0) {
        [mAsset insertEntry:mEditingEntry];
    } else {
        [mAsset replaceEntryAtIndex:mTransactionIndex withObject:mEditingEntry];
        //[asset sortByDate];
    }
    self.editingEntry = nil;

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancelAction
{
    if (mIsModified) {
        mAsCancelTransaction =
            [[UIActionSheet alloc]
                initWithTitle:_L(@"Save this transaction?")
                delegate:self
             cancelButtonTitle:_L(@"Cancel")
                destructiveButtonTitle:nil
                otherButtonTitles:_L(@"Yes"), _L(@"No"), nil];
        mAsCancelTransaction.actionSheetStyle = UIActionSheetStyleDefault;
        [mAsCancelTransaction showInView:self.view];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)_asCancelTransaction:(int)buttonIndex
{
    switch (buttonIndex) {
    case 0:
        // save
        [self saveAction];
        break;

    case 1:
        // do not save
        [self.navigationController popViewControllerAnimated:YES];
        break;

    case 2:
        // cancel
        break;
    }
}

#pragma mark ActionSheetDelegate

- (void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet == mAsDelPast) {
        [self _asDelPast:buttonIndex];
    }
    else if (actionSheet == mAsCancelTransaction) {
        [self _asCancelTransaction:buttonIndex];
    }
}

#pragma mark Rotation support

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (IS_IPAD) return YES;
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
