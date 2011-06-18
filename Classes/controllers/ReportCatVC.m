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

@synthesize reportEntry = mReportEntry;

- (id)init
{
    self = [super initWithNibName:@"SimpleTableView" bundle:nil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [AppDelegate trackPageview:@"/ReportCatViewController"];
    
    self.navigationItem.rightBarButtonItem =
        [[[UIBarButtonItem alloc]
             initWithBarButtonSystemItem:UIBarButtonSystemItemDone
             target:self
             action:@selector(doneAction:)] autorelease];
}

- (void)doneAction:(id)sender
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [mReportEntry release];
    [super dealloc];
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
            value = mReportEntry.totalOutgo;
            break;
        case 1:
            head = _L(@"Income");
            value = mReportEntry.totalIncome;
            break;
            
        case 2:
            head = _L(@"Total");
            value = mReportEntry.totalOutgo + mReportEntry.totalIncome;
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
            rows = [mReportEntry.outgoCatReports count];
            break;
        case 1:
            rows = [mReportEntry.incomeCatReports count];
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
        ReportCatGraphCell *cell = [ReportCatGraphCell reportCatGraphCell:tv];
        [cell setReport:mReportEntry isOutgo:(indexPath.section == 0 ? YES : NO)];
        return cell;
    } else {
        ReportCatCell *cell = [ReportCatCell reportCatCell:tv];

        CatReport *cr = nil;
        switch (indexPath.section) {
            case 0:
                cr = [mReportEntry.outgoCatReports objectAtIndex:indexPath.row - 1];
                [cell setValue:-cr.sum maxValue:-mReportEntry.totalOutgo];
                break;

            case 1:
                cr = [mReportEntry.incomeCatReports objectAtIndex:indexPath.row - 1];
                [cell setValue:cr.sum maxValue:mReportEntry.totalIncome];
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
        cr = [mReportEntry.outgoCatReports objectAtIndex:indexPath.row - 1];
        break;
    case 1:
        cr = [mReportEntry.incomeCatReports objectAtIndex:indexPath.row - 1];
        break;
    }

    CatReportDetailViewController *vc = [[[CatReportDetailViewController alloc] init] autorelease];
    vc.title = [cr title];
    vc.catReport = cr;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (IS_IPAD) return YES;
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
