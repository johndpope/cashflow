// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "TransactionVC.h"
#import "AppDelegate.h"

@implementation TransactionViewController

@synthesize editingEntry = mEditingEntry;
@synthesize asset = mAsset;

#define ROW_DATE  0
#define ROW_TYPE  1
#define ROW_VALUE 2
#define ROW_DESC  3
#define ROW_CATEGORY 4
#define ROW_MEMO  5

#define NUM_ROWS 6

- (id)init
{
    self = [super initWithNibName:@"TransactionView" bundle:nil];
    return self;
}

- (void)viewDidLoad
{
    mIsModified = NO;

    self.title = _L(@"Transaction");
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
                                                  initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                  target:self
                                                  action:@selector(saveAction)] autorelease];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]
                                                  initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                  target:self
                                                  action:@selector(cancelAction)] autorelease];

    mTypeArray = [[NSArray alloc] initWithObjects:
                                     _L(@"Payment"),
                                 _L(@"Deposit"),
                                 _L(@"Adjustment"),
                                 _L(@"Transfer"),
                                 nil];
	
    // ボタン生成
    UIButton *b;
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
            mDelButton = [b retain];
        } else {
            rect.origin.y += 55;
            [b setFrame:rect];
            [b setTitle:_L(@"Delete with all past transactions") forState:UIControlStateNormal];
            [b addTarget:self action:@selector(delPastButtonTapped) forControlEvents:UIControlEventTouchUpInside];
            mDelPastButton = [b retain];
        }

        b.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self.view addSubview:b];
        //[self.view bringSubviewToFront:b];
    }
}

- (void)dealloc
{
    self.editingEntry = nil;
	
    [mTypeArray release];
    [mDelButton release];
    [mDelPastButton release];
	
    [super dealloc];
}

// 処理するトランザクションをロードしておく
- (void)setTransactionIndex:(int)n
{
    mTransactionIndex = n;

    self.editingEntry = nil;

    if (mTransactionIndex < 0) {
        // 新規トランザクション
        self.editingEntry = [[[AssetEntry alloc] initWithTransaction:nil withAsset:mAsset] autorelease];
    } else {
        // 変更
        AssetEntry *orig = [mAsset entryAt:mTransactionIndex];
        self.editingEntry = [[orig copy] autorelease];
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
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:MyIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        /*
        name = [[[UILabel alloc] initWithFrame:CGRectMake(0, 6, 110, 32)] autorelease];
        name.tag = 1;
        name.font = [UIFont systemFontOfSize: 14.0];
        name.textColor = [UIColor blueColor];
        name.textAlignment = UITextAlignmentRight;
        name.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [cell.contentView addSubview:name];

        value = [[[UILabel alloc] initWithFrame:CGRectMake(90, 6, 210, 32)] autorelease];
        value.tag = 2;
        value.font = [UIFont systemFontOfSize: 16.0];
        value.textColor = [UIColor blackColor];
        value.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [cell.contentView addSubview:value];
         */
    } else {
        //name  = (UILabel *)[cell.contentView viewWithTag:1];
        //value = (UILabel *)[cell.contentView viewWithTag:2];
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
        value.text = [mTypeArray objectAtIndex:mEditingEntry.transaction.type];
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
    EditDateViewController *editDateVC;
    EditTypeViewController *editTypeVC; // type
    CalculatorViewController *calcVC;
    EditDescViewController *editDescVC;
    EditMemoViewController *editMemoVC; // memo
    CategoryListViewController *editCategoryVC;

    // view を表示

    switch (indexPath.row) {
    case ROW_DATE:
        editDateVC = [[[EditDateViewController alloc] init] autorelease];
        editDateVC.delegate = self;
        editDateVC.date = mEditingEntry.transaction.date;
        vc = editDateVC;
        break;

    case ROW_TYPE:
        editTypeVC = [[[EditTypeViewController alloc] init] autorelease];
        editTypeVC.delegate = self;
        editTypeVC.type = mEditingEntry.transaction.type;
        editTypeVC.dstAsset = [mEditingEntry dstAsset];
        vc = editTypeVC;
        break;

    case ROW_VALUE:
        calcVC = [[[CalculatorViewController alloc] init] autorelease];
        calcVC.delegate = self;
        calcVC.value = mEditingEntry.evalue;
        vc = calcVC;
        break;

    case ROW_DESC:
        editDescVC = [[[EditDescViewController alloc] init] autorelease];
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
        editCategoryVC = [[[CategoryListViewController alloc] init] autorelease];
        editCategoryVC.isSelectMode = YES;
        editCategoryVC.delegate = self;
        editCategoryVC.selectedIndex = [[DataModel categories] categoryIndexWithKey:mEditingEntry.transaction.category];
        vc = editCategoryVC;
        break;
    }
    
    if (IS_IPAD) { // TBD
        nc = [[[UINavigationController alloc] initWithRootViewController:vc] autorelease];
        
        if (mCurrentPopoverController != nil) {
            [mCurrentPopoverController release];
        }
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
        [mCurrentPopoverController release];
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
- (void)editDateViewChanged:(EditDateViewController *)vc
{
    mIsModified = YES;

    mEditingEntry.transaction.date = vc.date;
    [self _dismissPopover];
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
        mEditingEntry.transaction.description = [mTypeArray objectAtIndex:mEditingEntry.transaction.type];
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
        Category *c = [[DataModel categories] categoryAtIndex:vc.selectedIndex];
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
    [mAsDelPast release];
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
        [mAsCancelTransaction release];
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
