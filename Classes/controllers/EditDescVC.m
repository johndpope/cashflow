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

@implementation EditDescViewController

@synthesize delegate = mDelegate, description = mDescription, category = mCategory, tableView = mTableView;

- (id)init
{
    self = [super initWithNibName:@"EditDescView" bundle:nil];
    if (self) {
        mCategory = -1;
        mDescArray = nil;
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
        [[[UIBarButtonItem alloc]
             initWithBarButtonSystemItem:UIBarButtonSystemItemDone
             target:self
             action:@selector(doneAction)] autorelease];

    // ここで textField を生成する
    mTextField = [[UITextField alloc] initWithFrame:CGRectMake(12, 12, 300, 24)];
    mTextField.placeholder = _L(@"Description");
    mTextField.returnKeyType = UIReturnKeyDone;
    mTextField.delegate = self;
    [mTextField addTarget:self action:@selector(onTextChange:)
               forControlEvents:UIControlEventEditingDidEndOnExit];
}

-(void)onTextChange:(id)sender {
    // dummy func must exist for textFieldShouldReturn event to be called
}

- (void)dealloc
{
    [mTableView release];
    [mTextField release];
    [mDescription release];
    [mDescArray release];
    [super dealloc];
}

// 表示前の処理
//  処理するトランザクションをロードしておく
- (void)viewWillAppear:(BOOL)animated
{
    mTextField.text = self.description;
    [super viewWillAppear:animated];

    [mDescArray release];
    mDescArray = [DescLRUManager getDescLRUs:mCategory];
    [mDescArray retain];

    // キーボードを消す ###
    [mTextField resignFirstResponder];

    [mTableView reloadData];
}

//- (void)viewWillDisappear:(BOOL)animated
//{
//    [super viewWillDisappear:animated];
//}

- (void)doneAction
{
    self.description = mTextField.text;
    [mDelegate editDescViewChanged:self];

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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1; // テキスト入力欄
    }

    return [mDescArray count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
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

    if (indexPath.section == 0) {
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
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"textFieldCell"] autorelease];
        [cell.contentView addSubview:mTextField];
    }
    return cell;
}

- (UITableViewCell *)_descCell:(UITableView *)tv row:(int)row
{   
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:@"descCell"];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"descCell"] autorelease];
    }
    DescLRU *lru = [mDescArray objectAtIndex:row];
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

    if (indexPath.section == 1) {
        DescLRU *lru = [mDescArray objectAtIndex:indexPath.row];
        mTextField.text = lru.description;
        [self doneAction];
    }
}

// 編集スタイルを返す
- (UITableViewCellEditingStyle)tableView:(UITableView*)tv editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return UITableViewCellEditingStyleNone;
    }
    // 適用は削除可能
    return UITableViewCellEditingStyleDelete;
}

// 削除処理
- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)style forRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section != 1 ||
        style != UITableViewCellEditingStyleDelete) {
        return; // do nothing
    }

    DescLRU *lru = [mDescArray objectAtIndex:indexPath.row];
    [lru delete]; // delete from DB

    [mDescArray removeObjectAtIndex:indexPath.row];

    [tv deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark -

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (IS_IPAD) return YES;
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
