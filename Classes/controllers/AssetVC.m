// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "AssetVC.h"
#import "AppDelegate.h"
#import "GenEditTextVC.h"
#import "GenSelectListVC.h"

@implementation AssetViewController

//@synthesize asset = mAsset;

#define ROW_NAME  0
#define ROW_TYPE  1

- (id)init
{
    self = [super initWithNibName:@"AssetView" bundle:nil];
    return self;
}

- (void)viewDidLoad
{
    self.title = _L(@"Asset");
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
                                                  initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                  target:self
                                                  action:@selector(saveAction)] autorelease];

    // ボタン生成
#if 0
    UIButton *b;
    UIImage *bg = [[UIImage imageNamed:@"redButton.png"] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0];
				
    b = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [b setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [b setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
	
    [b setBackgroundImage:bg forState:UIControlStateNormal];
		
    [b setFrame:CGRectMake(10, 280, 300, 44)];
    [b setTitle:_L(@"Delete Asset") forState:UIControlStateNormal];
    [b addTarget:self action:@selector(delButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    delButton = [b retain];
#endif
}

- (void)dealloc
{
    [mDelButton release];
	
    [super dealloc];
}

// 処理するトランザクションをロードしておく
- (void)setAssetIndex:(int)n
{
    mAssetIndex = n;

    if (mAsset != nil) {
        [mAsset release];
    }
    if (mAssetIndex < 0) {
        // 新規
        mAsset = [[Asset alloc] init];
        mAsset.name = @"";
        mAsset.sorder = 99999;
    } else {
        // 変更
        mAsset = [[DataModel ledger] assetAtIndex:mAssetIndex];
    }
}

// 表示前の処理
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
    if (mAssetIndex >= 0) {
        [self.view addSubview:mDelButton];
    }
		
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
	
    if (mAssetIndex >= 0) {
        [mDelButton removeFromSuperview];
    }
}

/////////////////////////////////////////////////////////////////////////////////
// TableView 表示処理

// セクション数
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

// 行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    return 2;
}

// 行の内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *MyIdentifier = @"assetViewCells";
    UILabel *name, *value;

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:MyIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        /*
        name = [[[UILabel alloc] initWithFrame:CGRectMake(0, 6, 160, 32)] autorelease];
        name.tag = 1;
        name.font = [UIFont systemFontOfSize: 14.0];
        name.textColor = [UIColor blueColor];
        name.backgroundColor = [UIColor clearColor];
        name.textAlignment = UITextAlignmentRight;
        name.autoresizingMask = 0; //UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [cell.contentView addSubview:name];

        value = [[[UILabel alloc] initWithFrame:CGRectMake(130, 6, 160, 32)] autorelease];
        value.tag = 2;
        value.font = [UIFont systemFontOfSize: 16.0];
        value.textColor = [UIColor blackColor];
        value.backgroundColor = [UIColor clearColor];
        value.autoresizingMask = 0; //UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [cell.contentView addSubview:value];
         */
    } else {
        //name  = (UILabel *)[cell.contentView viewWithTag:1];
        //value = (UILabel *)[cell.contentView viewWithTag:2];
    }

    name = cell.textLabel;
    value = cell.detailTextLabel;
    
    switch (indexPath.row) {
    case ROW_NAME:
        name.text = _L(@"Asset Name");
        value.text = mAsset.name;
        break;

    case ROW_TYPE:
        name.text = _L(@"Asset Type");
        switch (mAsset.type) {
        case ASSET_CASH:
            value.text = _L(@"Cash");
            break;
        case ASSET_BANK:
            value.text = _L(@"Bank Account");
            break;
        case ASSET_CARD:
            value.text = _L(@"Credit Card");
            break;
        }
        break;
    }

    return cell;
}

///////////////////////////////////////////////////////////////////////////////////
// 値変更処理

// セルをクリックしたときの処理
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UINavigationController *nc = self.navigationController;

    // view を表示
    UIViewController *vc = nil;
    GenEditTextViewController *ge;
    GenSelectListViewController *gt;
    NSArray *typeArray;

    switch (indexPath.row) {
    case ROW_NAME:
        ge = [GenEditTextViewController genEditTextViewController:self title:_L(@"Asset Name") identifier:0];
        ge.text = mAsset.name;
        vc = ge;
        break;

    case ROW_TYPE:
        typeArray = [[[NSArray alloc]initWithObjects:
                                         _L(@"Cash"),
                                     _L(@"Bank Account"),
                                     _L(@"Credit Card"),
                                     nil] autorelease];
        gt = [GenSelectListViewController genSelectListViewController:self 
                                        items:typeArray 
                                        title:_L(@"Asset Type")
                                        identifier:0];
        gt.selectedIndex = mAsset.type;
        vc = gt;
        break;
    }
	
    if (vc != nil) {
        [nc pushViewController:vc animated:YES];
    }
}

// delegate : 下位 ViewController からの変更通知
- (void)genEditTextViewChanged:(GenEditTextViewController *)vc identifier:(int)id
{
    mAsset.name = vc.text;
}

- (BOOL)genSelectListViewChanged:(GenSelectListViewController *)vc identifier:(int)id
{
    mAsset.type = vc.selectedIndex;
    return YES;
}


////////////////////////////////////////////////////////////////////////////////
// 削除処理
#if 0
- (void)delButtonTapped
{
    UIActionSheet *as = [[UIActionSheet alloc]
                            initWithTitle:_L(@"ReallyDeleteAsset")
                            delegate:self
                            cancelButtonTitle:@"Cancel"
                            destructiveButtonTitle:_L(@"Delete Asset")
                            otherButtonTitles:nil];
    as.actionSheetStyle = UIActionSheetStyleDefault;
    [as showInView:self.view];
    [as release];
}

- (void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != 0) {
        return; // cancelled;
    }
	
    [[DataModel ledger] deleteAsset:asset];
    [self.navigationController popViewControllerAnimated:YES];
}
#endif

////////////////////////////////////////////////////////////////////////////////
// 保存処理
- (void)saveAction
{
    Ledger *ledger = [DataModel ledger];

    if (mAssetIndex < 0) {
        [ledger addAsset:mAsset];
        [mAsset release];
    } else {
        [ledger updateAsset:mAsset];
    }
    mAsset = nil;
	
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (IS_IPAD) return YES;
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
