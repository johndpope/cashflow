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
{
    IBOutlet UITableView *_tableView;
    
    IBOutlet UIButton *_delButton;
    IBOutlet UIBarButtonItem *_barActionButton;
    IBOutlet UIView *_rememberDateView;
    IBOutlet UILabel *_rememberDateLabel;
    IBOutlet UISwitch *_rememberDateSwitch;

    int _transactionIndex;

    BOOL _isModified;

    NSArray *_typeArray;
	
    UIActionSheet *_asCancelTransaction;
    UIActionSheet *_asAction;
    
    UIPopoverController *_currentPopoverController;
}

@end

@implementation TransactionViewController

#define ROW_DATE  0
#define ROW_TYPE  1
#define ROW_VALUE 2
#define ROW_DESC  3
#define ROW_CATEGORY 4
#define ROW_MEMO  5

#define NUM_ROWS 6

// for debug
#define REFCOUNT(x) CFGetRetainCount((__bridge void *)(x))

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //[AppDelegate trackPageview:@"/TransactionViewController"];
    
    _isModified = NO;

    self.title = _L(@"Transaction");
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                  initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                  target:self
                                                  action:@selector(saveAction)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                                  initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                  target:self
                                                  action:@selector(cancelAction)];

    _typeArray = @[_L(@"Payment"),
                                 _L(@"Deposit"),
                                 _L(@"Adjustment"),
                                 _L(@"Transfer")];
    
    [_rememberDateLabel setText:_L(@"Remember Date")];
    
    if ([self isNewTransaction]) {
        // 日付記憶関連処理
        [_rememberDateSwitch setOn:[Transaction hasLastUsedDate]];
    }
    
    // 削除ボタンの背景と位置調整
    //UIImage *bg = [[UIImage imageNamed:@"redButton.png"] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0];
    //[_delButton setBackgroundImage:bg forState:UIControlStateNormal];
    [_delButton setTitle:_L(@"Delete transaction") forState:UIControlStateNormal];
    
    /*if (IS_IPAD) {
        CGRect rect;
        rect = _delButton.frame;
        rect.origin.y += 100;
        _delButton.frame = rect;
    }*/

    /*
    // ボタン生成
    // TODO:
    // b を unsafe unretained にしておかないと、オブジェクトのリファレンスカウンタが足りなくなりクラッシュする。
    // ARC 周りのバグか？
    __unsafe_unretained UIButton *b;
     
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
    }*/
    
}

// 処理するトランザクションをロードしておく
- (void)setTransactionIndex:(int)n
{
    _transactionIndex = n;

    self.editingEntry = nil;

    if (_transactionIndex < 0) {
        // 新規トランザクション
        self.editingEntry = [[AssetEntry alloc] initWithTransaction:nil withAsset:_asset];
    } else {
        // 変更
        AssetEntry *orig = [_asset entryAt:_transactionIndex];
        self.editingEntry = [orig copy];
    }
}

- (BOOL)isNewTransaction
{
    return (_transactionIndex < 0);
}

// 表示前の処理
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    BOOL isNewTransaction = [self isNewTransaction];
	
    _delButton.hidden = isNewTransaction;
    //_delPastButton.hidden = isNewTransaction;
	
	_rememberDateView.hidden = !isNewTransaction;

    [[self tableView] reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //[[self tableView] reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self dismissPopover];
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
        value.text = [[DataModel dateFormatter] stringFromDate:_editingEntry.transaction.date];
        break;

    case ROW_TYPE:
        name.text = _L(@"Type"); // @"Transaction type"
        value.text = _typeArray[_editingEntry.transaction.type];
        break;
		
    case ROW_VALUE:
        name.text = _L(@"Amount");
        evalue = _editingEntry.evalue;
        value.text = [CurrencyManager formatCurrency:evalue];
        break;
		
    case ROW_DESC:
        name.text = _L(@"Name");
        value.text = _editingEntry.transaction.description;
        break;
			
    case ROW_CATEGORY:
        name.text = _L(@"Category");
        value.text = [[DataModel categories] categoryStringWithKey:_editingEntry.transaction.category];
        break;
			
    case ROW_MEMO:
        name.text = _L(@"Memo");
        value.text = _editingEntry.transaction.memo;
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
                calendarVc.selectedDate = _editingEntry.transaction.date;
                [calendarVc setCalendarViewControllerDelegate:self];
                vc = calendarVc;
            } else {
                EditDateViewController *editDateVC = [EditDateViewController instantiate];
                editDateVC.delegate = self;
                editDateVC.date = _editingEntry.transaction.date;
                vc = editDateVC;
            }
            break;

        case ROW_TYPE:
            editTypeVC = [EditTypeViewController new];
            editTypeVC.delegate = self;
            editTypeVC.type = _editingEntry.transaction.type;
            editTypeVC.dstAsset = [_editingEntry dstAsset];
            vc = editTypeVC;
            break;

        case ROW_VALUE:
            calcVC = [CalculatorViewController instantiate];
            calcVC.delegate = self;
            calcVC.value = _editingEntry.evalue;
            vc = calcVC;
            break;

        case ROW_DESC:
            editDescVC = [EditDescViewController instantiate];
            editDescVC.delegate = self;
            editDescVC.description = _editingEntry.transaction.description;
            editDescVC.category = _editingEntry.transaction.category;
            vc = editDescVC;
            break;

        case ROW_MEMO:
            editMemoVC = [EditMemoViewController
                          editMemoViewController:self
                          title:_L(@"Memo") 
                          identifier:0];
            editMemoVC.text = _editingEntry.transaction.memo;
            vc = editMemoVC;
            break;

        case ROW_CATEGORY:
            editCategoryVC = [CategoryListViewController new];
            editCategoryVC.isSelectMode = YES;
            editCategoryVC.delegate = self;
            editCategoryVC.selectedIndex = [[DataModel categories] categoryIndexWithKey:_editingEntry.transaction.category];
            vc = editCategoryVC;
            break;
    }
            
    if (IS_IPAD) { // TBD
        nc = [[UINavigationController alloc] initWithRootViewController:vc];
        
        _currentPopoverController = [[UIPopoverController alloc] initWithContentViewController:nc];
        _currentPopoverController.delegate = self;
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        CGRect rect = cell.frame;
        [_currentPopoverController presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else {
        [nc pushViewController:vc animated:YES];
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    if (IS_IPAD && _currentPopoverController != nil) {
        _currentPopoverController = nil;
    }
}

- (void)dismissPopover
{
    if (IS_IPAD) {
        if (_currentPopoverController != nil
            && [_currentPopoverController isPopoverVisible]
            && self.view != nil && self.view.window != nil /* for crash problem */) {
            [_currentPopoverController dismissPopoverAnimated:YES];
        }
        [self.tableView reloadData];
    }
}

#pragma mark EditView delegates

// delegate : 下位 ViewController からの変更通知

- (void)calendarViewController:(CalendarViewController *)aCalendarViewController dateDidChange:(NSDate *)aDate
{
    if (aDate == nil) return; // do nothing (Clear button)
    
    _isModified = YES;
    _editingEntry.transaction.date = aDate;
    //[self checkLastUsedDate:aDate];

    if (IS_IPAD) {
        [self dismissPopover];
    }
    // Si-Calendar は、選択時に自動で View を閉じない仕様なので、ここで閉じる
    [aCalendarViewController.navigationController popViewControllerAnimated:YES];
}

- (void)editDateViewChanged:(EditDateViewController *)vc
{
    _isModified = YES;

    _editingEntry.transaction.date = vc.date;
    //[self checkLastUsedDate:vc.date];
    
    [self dismissPopover];
}

// 入力した日付が現在時刻から離れている場合のみ、日付を記憶
#if 0 // No longer used
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
#endif

- (void)editTypeViewChanged:(EditTypeViewController*)vc
{
    _isModified = YES;

    // autoPop == NO なので、自分で pop する
    [self.navigationController popToViewController:self animated:YES];

    if (![_editingEntry changeType:vc.type assetKey:_asset.pid dstAssetKey:vc.dstAsset]) {
        return;
    }

    switch (_editingEntry.transaction.type) {
    case TYPE_ADJ:
        _editingEntry.transaction.description = _typeArray[_editingEntry.transaction.type];
        break;

    case TYPE_TRANSFER:
        {
            Asset *from, *to;
            Ledger *ledger = [DataModel ledger];
            from = [ledger assetWithKey:_editingEntry.transaction.asset];
            to = [ledger assetWithKey:_editingEntry.transaction.dstAsset];

            _editingEntry.transaction.description = 
                [NSString stringWithFormat:@"%@/%@", from.name, to.name];
        }
        break;

    default:
        break;
    }

    [self dismissPopover];
}

- (void)calculatorViewChanged:(CalculatorViewController *)vc
{
    _isModified = YES;

    [_editingEntry setEvalue:vc.value];
    [self dismissPopover];
}

- (void)editDescViewChanged:(EditDescViewController *)vc
{
    _isModified = YES;

    _editingEntry.transaction.description = vc.description;

    if (_editingEntry.transaction.category < 0) {
        // set category from description
        _editingEntry.transaction.category = [[DataModel instance] categoryWithDescription:_editingEntry.transaction.description];
    }
    [self dismissPopover];
}

- (void)editMemoViewChanged:(EditMemoViewController*)vc identifier:(int)id
{
    _isModified = YES;

    _editingEntry.transaction.memo = vc.text;
    [self dismissPopover];
}

- (void)categoryListViewChanged:(CategoryListViewController*)vc;
{
    _isModified = YES;

    if (vc.selectedIndex < 0) {
        _editingEntry.transaction.category = -1;
    } else {
        TCategory *c = [[DataModel categories] categoryAtIndex:vc.selectedIndex];
        _editingEntry.transaction.category = c.pid;
    }
    [self dismissPopover];
}

- (IBAction)rememberLastUsedDateChanged:(id)view
{
    if ([_rememberDateSwitch isOn]) {
        [Transaction setLastUsedDate:_editingEntry.transaction.date];
    } else {
        [Transaction setLastUsedDate:nil];
    }
}

////////////////////////////////////////////////////////////////////////////////
// 削除処理

#pragma mark Deletion

- (IBAction)delButtonTapped:(id)sender
{
    [_asset deleteEntryAt:_transactionIndex];
    self.editingEntry = nil;
	
    [self.navigationController popViewControllerAnimated:YES];
}

////////////////////////////////////////////////////////////////////////////////
// ツールバー

- (IBAction)doAction:(id)sender {
    UIActionSheet *as =
    [[UIActionSheet alloc]
     initWithTitle:nil
     delegate:self
     cancelButtonTitle:_L(@"Cancel")
     destructiveButtonTitle:nil otherButtonTitles:
     _L(@"Delete with all past transactions"), nil];
    if (IS_IPAD) {
        [as showFromBarButtonItem:_barActionButton animated:YES];
    } else {
        [as showInView:[self view]];
    }
    _asAction = as;
}

- (void)asAction:(NSInteger)buttonIndex
{
    if (buttonIndex != 0) {
        return;
    }
    if (![self isNewTransaction]) {
        [self delPastButtonTapped:nil];
    }
}

- (void)delPastButtonTapped:(id)sender
{
    UIAlertView *v = [[UIAlertView alloc]
                      initWithTitle:_L(@"Delete with all past transactions")
                      message:_L(@"You can not cancel this operation.")
                      delegate:self cancelButtonTitle:_L(@"Cancel") otherButtonTitles:_L(@"Ok"),nil];
    [v show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != 1) {
        return; // cancelled;
    }
    
    AssetEntry *e = [_asset entryAt:_transactionIndex];
	
    NSDate *date = e.transaction.date;
    [_asset deleteOldEntriesBefore:date];
	
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
    if (_transactionIndex < 0) {
        // 新規追加
        [_asset insertEntry:_editingEntry];
        
        if ([_rememberDateSwitch isOn]) {
            [Transaction setLastUsedDate:_editingEntry.transaction.date];
        }
    } else {
        [_asset replaceEntryAtIndex:_transactionIndex withObject:_editingEntry];
        //[asset sortByDate];
    }
    self.editingEntry = nil;

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancelAction
{
    if (_isModified) {
        _asCancelTransaction =
            [[UIActionSheet alloc]
                initWithTitle:_L(@"Save this transaction?")
                delegate:self
             cancelButtonTitle:_L(@"Cancel")
                destructiveButtonTitle:nil
                otherButtonTitles:_L(@"Yes"), _L(@"No"), nil];
        _asCancelTransaction.actionSheetStyle = UIActionSheetStyleDefault;
        [_asCancelTransaction showInView:self.view];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)asCancelTransaction:(int)buttonIndex
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
    if (actionSheet == _asCancelTransaction) {
        [self asCancelTransaction:buttonIndex];
    }
    else if (actionSheet == _asAction) {
        [self asAction:buttonIndex];
    }
}

#pragma mark Rotation support

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (IS_IPAD) return YES;
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
