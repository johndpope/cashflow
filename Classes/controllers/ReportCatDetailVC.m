// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "AppDelegate.h"
#import "DataModel.h"
#import "Report.h"
#import "ReportCatDetailVC.h"
#import "TransactionCell.h"

@implementation CatReportDetailViewController

- (id)init
{
    self = [super initWithNibName:@"SimpleTableView" bundle:nil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[AppDelegate trackPageview:@"/ReportCatDetailViewController"];
    
    self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc]
             initWithBarButtonSystemItem:UIBarButtonSystemItemDone
             target:self
             action:@selector(doneAction:)];
}

- (void)doneAction:(id)sender
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_catReport.transactions count];
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TransactionCell *cell = [TransactionCell transactionCell:tv];
    
    Transaction *t = (_catReport.transactions)[[_catReport.transactions count] - 1 - indexPath.row];
    double value;
    if (_catReport.assetKey < 0) {
        // 全資産指定の場合
        value = t.value;
    } else {
        // 資産指定の場合
        if (t.asset == _catReport.assetKey) {
            value = t.value;
        } else {
            value = -t.value;
        }
    }
    [cell setDescriptionLabel:t.description];
    [cell setDateLabel:t.date];
    [cell setValueLabel:value];
    [cell clearBalanceLabel];

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (IS_IPAD) return YES;
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
