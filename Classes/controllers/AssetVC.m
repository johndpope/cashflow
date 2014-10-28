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
{
    NSInteger _assetIndex;
    Asset *_asset;

    UIButton *_delButton;
}

#define ROW_NAME  0
#define ROW_TYPE  1

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //[AppDelegate trackPageview:@"/AssetViewController"];
    
    self.title = _L(@"Asset");
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                  initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                  target:self
                                                  action:@selector(saveAction)];
}


// 処理するトランザクションをロードしておく
- (void)setAssetIndex:(NSInteger)n
{
    _assetIndex = n;

    if (_assetIndex < 0) {
        // 新規
        _asset = [Asset new];
        _asset.name = @"";
        _asset.sorder = 99999;
    } else {
        // 変更
        _asset = [[DataModel ledger] assetAtIndex:_assetIndex];
    }
}

// 表示前の処理
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
    if (_assetIndex >= 0) {
        [self.view addSubview:_delButton];
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
	
    if (_assetIndex >= 0) {
        [_delButton removeFromSuperview];
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
    static NSString *MyIdentifier = @"assetViewCell";
    UILabel *name, *value;

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    /* Storyboard で指定するので不要になった
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:MyIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }*/

    name = cell.textLabel;
    value = cell.detailTextLabel;
    
    switch (indexPath.row) {
    case ROW_NAME:
        name.text = _L(@"Asset Name");
        value.text = _asset.name;
        break;

    case ROW_TYPE:
        name.text = _L(@"Asset Type");
        value.text = [Asset typeNameWithType:_asset.type];
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
        ge.text = _asset.name;
        vc = ge;
        break;

    case ROW_TYPE:
        typeArray = [Asset typeNamesArray];
        gt = [GenSelectListViewController genSelectListViewController:self 
                                        items:typeArray 
                                        title:_L(@"Asset Type")
                                        identifier:0];
        gt.selectedIndex = _asset.type;
        vc = gt;
        break;
    }
	
    if (vc != nil) {
        [nc pushViewController:vc animated:YES];
    }
}

// delegate : 下位 ViewController からの変更通知
- (void)genEditTextViewChanged:(GenEditTextViewController *)vc identifier:(NSInteger)id
{
    _asset.name = vc.text;
}

- (BOOL)genSelectListViewChanged:(GenSelectListViewController *)vc identifier:(NSInteger)id
{
    _asset.type = vc.selectedIndex;
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

    if (_assetIndex < 0) {
        [ledger addAsset:_asset];
    } else {
        [ledger updateAsset:_asset];
    }
    _asset = nil;
	
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return IS_IPAD || interfaceOrientation == UIInterfaceOrientationPortrait;
}

@end
