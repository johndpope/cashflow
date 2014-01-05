// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "TransactionVC.h"
#import "EditDescVC.h"
#import "AppDelegate.h"
#import "DescLRUManager.h"

@interface EditDescViewController()
- (UITableViewCell *)_textFieldCell:(UITableView*)tv;
- (UITableViewCell *)_descCell:(UITableView*)tv row:(int)row;

@property (nonatomic) NSMutableArray *descArray;
@property (nonatomic) NSMutableArray *filteredDescArray;

@end

@implementation EditDescViewController
{
    UITextField *_textField;
}

+ (EditDescViewController *)instantiate {
    return [[UIStoryboard storyboardWithName:@"EditDescView" bundle:nil] instantiateInitialViewController];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _category = -1;
    }
    return self;
}

- (void)viewDidLoad
{
    if (IS_IPAD) {
        CGSize s = self.contentSizeForViewInPopover;
        s.height = 600;  // AdHoc : 480 にすると横画面の時に下に出てしまい、文字入力ができない
        self.contentSizeForViewInPopover = s;
    }
    
    self.title = _L(@"Name");

    self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc]
             initWithBarButtonSystemItem:UIBarButtonSystemItemDone
             target:self
             action:@selector(doneAction)];

    // ここで textField を生成する
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(12, 12, 300, 24)];
    _textField.placeholder = _L(@"Description");
    _textField.returnKeyType = UIReturnKeyDone;
    _textField.delegate = self;
    
    /*
    [mTextField addTarget:self action:@selector(onTextChange:)
               forControlEvents:UIControlEventEditingDidEndOnExit];
     */
}

// 表示前の処理
//  処理するトランザクションをロードしておく
- (void)viewWillAppear:(BOOL)animated
{
    _textField.text = self.description;
    [super viewWillAppear:animated];

    self.descArray = [DescLRUManager getDescLRUs:_category];
    self.filteredDescArray = [self.descArray mutableCopy];

    // キーボードを消す ###
    [_textField resignFirstResponder];

    [self.tableView reloadData];
}

//- (void)viewWillDisappear:(BOOL)animated
//{
//    [super viewWillDisappear:animated];
//}

- (void)doneAction
{
    self.description = _textField.text;
    [_delegate editDescViewChanged:self];

    [self.navigationController popViewControllerAnimated:YES];
}

// キーボードを消すための処理
- (BOOL)textFieldShouldReturn:(UITextField*)t
{
    [t resignFirstResponder];
    return YES;
}

#pragma mark TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
    } else {
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView != self.searchDisplayController.searchResultsTableView && section == 0) {
        return 1; // テキスト入力欄
    }

    return [self.filteredDescArray count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return nil;
    }
    switch (section) {
        case 0:
            return _L(@"Name");
        case 1:
            return _L(@"History");
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;

    if (tv != self.searchDisplayController.searchResultsTableView && indexPath.section == 0) {
        cell = [self _textFieldCell:tv];
    } 
    else {
        cell = [self _descCell:tv row:indexPath.row];
    }
    return cell;
}

- (UITableViewCell *)_textFieldCell:(UITableView *)tv
{
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:@"textFieldCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"textFieldCell"];
        [cell.contentView addSubview:_textField];
    }
    return cell;
}

- (UITableViewCell *)_descCell:(UITableView *)tv row:(int)row
{   
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:@"descCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"descCell"];
    }
    DescLRU *lru = self.filteredDescArray[row];
    cell.textLabel.text = lru.description;
    return cell;
}

#pragma mark UITableViewDelegate

//
// セルをクリックしたときの処理
//
- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tv deselectRowAtIndexPath:indexPath animated:NO];

    if (tv == self.searchDisplayController.searchResultsTableView || indexPath.section == 1) {
        DescLRU *lru = self.filteredDescArray[indexPath.row];
        _textField.text = lru.description;
        [self doneAction];
    }
}

// 編集スタイルを返す
- (UITableViewCellEditingStyle)tableView:(UITableView*)tv editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tv != self.searchDisplayController.searchResultsTableView && indexPath.section == 0) {
        return UITableViewCellEditingStyleNone;
    }
    // 適用は削除可能
    return UITableViewCellEditingStyleDelete;
}

// 削除処理
- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)style forRowAtIndexPath:(NSIndexPath*)indexPath
{
    if ((tv != self.searchDisplayController.searchResultsTableView && indexPath.section != 1) ||
        style != UITableViewCellEditingStyleDelete) {
        return; // do nothing
    }

    DescLRU *lru = self.filteredDescArray[indexPath.row];
    [self.descArray removeObject:lru]; // フィルタ前リストから抜く
    [lru delete]; // delete from DB
    
    [self.filteredDescArray removeObjectAtIndex:indexPath.row];
    [tv deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - UISearchDisplayController Delegate

// iOS7 バグ回避
// see http://stackoverflow.com/questions/18924710/uisearchdisplaycontroller-overlapping-original-table-view
- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView
{
    tableView.backgroundColor = [UIColor whiteColor];
}

// 検索開始 : サーチバーの文字列が変更されたときに呼び出される
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self updateFilteredDescArray:searchString];
    return YES;
}

// 検索終了
- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    self.filteredDescArray = [self.descArray mutableCopy];
}


#pragma mark - 

// サーチテキスト変更時の処理：フィルタリングをし直す
- (void)updateFilteredDescArray:(NSString *)searchString {
    if (searchString == nil || searchString.length == 0) {
        self.filteredDescArray = [self.descArray mutableCopy];
        return;
    }
    
    int count = [self.descArray count];
    if (self.filteredDescArray == nil) {
        self.filteredDescArray = [[NSMutableArray alloc] initWithCapacity:count];
    } else {
        [self.filteredDescArray removeAllObjects];
    }
    
    NSUInteger searchOptions = NSCaseInsensitivePredicateOption | NSDiacriticInsensitiveSearch;
    for (int i = 0; i < count; i++) {
        DescLRU *lru = [self.descArray objectAtIndex:i];
        NSRange range = NSMakeRange(0, lru.description.length);
        NSRange foundRange = [lru.description rangeOfString:searchString options:searchOptions range:range];
        if (foundRange.length > 0) {
            [self.filteredDescArray addObject:lru];
        }
    }
}

#pragma mark -

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (IS_IPAD) return YES;
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
