// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "AppDelegate.h"
#import "DataModel.h"
#import "ReportCatVC.h"
#import "ReportCatCell.h"
#import "ReportCatGraphCell.h"
#import "ReportCatDetailVC.h"

@implementation CatReportViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[AppDelegate trackPageview:@"/ReportCatViewController"];
    
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
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *head = nil;
    double value = 0.0;
    
    switch (section) {
        case 0:
            head = _L(@"Outgo");
            value = _reportEntry.totalOutgo;
            break;
        case 1:
            head = _L(@"Income");
            value = _reportEntry.totalIncome;
            break;
            
        case 2:
            head = _L(@"Total");
            value = _reportEntry.totalOutgo + _reportEntry.totalIncome;
            break;
    }
                      
    NSString *title = [NSString stringWithFormat:@"%@ : %@", head,
                       [CurrencyManager formatCurrency:value]];
    return title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int rows = 0;

    switch (section) {
        case 0:
            rows = [_reportEntry.outgoCatReports count];
            break;
        case 1:
            rows = [_reportEntry.incomeCatReports count];
            break;
        case 2:
            return 0;
    }

    if (rows > 0) {
        return 1 + rows; // graph + rows
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tv heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return [ReportCatGraphCell cellHeight];
    } else {
        return [ReportCatCell cellHeight];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        /* graph cell */
        ReportCatGraphCell *cell = [tv dequeueReusableCellWithIdentifier:@"ReportCatGraphCell"];
        [cell setReport:_reportEntry isOutgo:(indexPath.section == 0 ? YES : NO)];
        return cell;
    } else {
        ReportCatCell *cell = [tv dequeueReusableCellWithIdentifier:@"ReportCatCell"];

        CatReport *cr = nil;
        switch (indexPath.section) {
            case 0:
                cr = (_reportEntry.outgoCatReports)[indexPath.row - 1];
                [cell setValue:-cr.sum maxValue:-_reportEntry.totalOutgo];
                break;

            case 1:
                cr = (_reportEntry.incomeCatReports)[indexPath.row - 1];
                [cell setValue:cr.sum maxValue:_reportEntry.totalIncome];
                break;
        }
        
        [cell setGraphColor:[ReportCatGraphCell getGraphColor:indexPath.row - 1]];
        cell.name = [cr title];

        return cell;
    }
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tv deselectRowAtIndexPath:indexPath animated:NO];
	
    if (indexPath.row == 0) return; // graph cell
    
    CatReport *cr = nil;
    switch (indexPath.section) {
    case 0:
        cr = (_reportEntry.outgoCatReports)[indexPath.row - 1];
        break;
    case 1:
        cr = (_reportEntry.incomeCatReports)[indexPath.row - 1];
        break;
    }

    CatReportDetailViewController *vc = [CatReportDetailViewController new];
    vc.title = [cr title];
    vc.catReport = cr;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (IS_IPAD) return YES;
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
