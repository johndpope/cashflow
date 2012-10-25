// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "AppDelegate.h"
#import "ReportVC.h"
#import "ReportCatVC.h"
#import "ReportCell.h"
#import "Config.h"

@interface ReportViewController()
- (IBAction)setReportDaily:(id)sender;
- (IBAction)setReportWeekly:(id)sender;
- (IBAction)setReportMonthly:(id)sender;
- (IBAction)setReportAnnual:(id)sender;

- (void)doneAction:(id)sender;
- (void)_updateReport;
- (NSString *)_reportTitle:(ReportEntry *)report;
@end

@implementation ReportViewController
{
    IBOutlet UITableView *mTableView;
    
    int mType;
    Asset *mDesignatedAsset;
    Report *mReports;
    double mMaxAbsValue;
    
    NSDateFormatter *mDateFormatter;
}

@synthesize tableView = mTableView;
@synthesize designatedAsset = mDesignatedAsset;

- (id)initWithAsset:(Asset*)asset type:(int)type
{
    self = [super initWithNibName:@"ReportView" bundle:nil];
    if (self != nil) {
        self.designatedAsset = asset;

        mType = type;

        mDateFormatter = [NSDateFormatter new];
        [self _updateReport];
    }
    return self;
}

- (id)initWithAsset:(Asset*)asset
{
    return [self initWithAsset:asset type:-1];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[AppDelegate trackPageview:@"/ReportViewController"];

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


/**
   レポート(再)生成
*/
- (void)_updateReport
{
    // レポート種別を設定から読み込む
    Config *config = [Config instance];
    if (mType < 0) {
        mType = config.lastReportType;
    }

    switch (mType) {
        default:
            mType = REPORT_DAILY;
            // FALLTHROUGH
        case REPORT_DAILY:
            self.title = _L(@"Daily Report");
            [mDateFormatter setDateFormat:@"yyyy/MM/dd"];
            break;

        case REPORT_WEEKLY:
            self.title = _L(@"Weekly Report");
            [mDateFormatter setDateFormat:@"yyyy/MM/dd~"];
            break;

        case REPORT_MONTHLY:
            self.title = _L(@"Monthly Report");
            //[dateFormatter setDateFormat:@"yyyy/MM"];
            [mDateFormatter setDateFormat:@"~yyyy/MM/dd"];
            break;

        case REPORT_ANNUAL:
            self.title = _L(@"Annual Report");
            [mDateFormatter setDateFormat:@"yyyy"];
            break;
    }

    // 設定保存
    config.lastReportType = mType;
    [config save];

    // レポート生成
    if (mReports == nil) {
        mReports = [Report new];
    }
    [mReports generate:mType asset:mDesignatedAsset];
    mMaxAbsValue = [mReports getMaxAbsValue];

    [self.tableView reloadData];
}

// レポートのタイトルを得る
- (NSString *)_reportTitle:(ReportEntry *)report
{
    if (mReports.type == REPORT_MONTHLY) {
        // 終了日の時刻の１分前の時刻から年月を得る
        //
        // 1) 締め日が月末の場合、endDate は翌月1日0:00を指しているので、
        //    1分前は当月最終日の23:59である。
        // 2) 締め日が任意の日、例えば25日の場合、endDate は当月25日を
        //    指している。そのまま年月を得る。
        NSDate *d = [report.end dateByAddingTimeInterval:-60];
        return [mDateFormatter stringFromDate:d];
    } else {
        return [mDateFormatter stringFromDate:report.start];
    }
}

#pragma mark Event Handlers

- (IBAction)setReportDaily:(id)sender
{
    mType = REPORT_DAILY;
    [self _updateReport];
}

- (IBAction)setReportWeekly:(id)sender;
{
    mType = REPORT_WEEKLY;
    [self _updateReport];
}

- (IBAction)setReportMonthly:(id)sender;
{
    mType = REPORT_MONTHLY;
    [self _updateReport];
}

- (IBAction)setReportAnnual:(id)sender;
{
    mType = REPORT_ANNUAL;
    [self _updateReport];
}

#pragma mark TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [mReports.reportEntries count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [ReportCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int count = [mReports.reportEntries count];
    ReportEntry *report = (mReports.reportEntries)[count - indexPath.row - 1];
	
    ReportCell *cell = [ReportCell reportCell:tv];
    cell.name = [self _reportTitle:report];
    cell.income = report.totalIncome;
    cell.outgo = report.totalOutgo;
    cell.maxAbsValue = mMaxAbsValue;
    [cell updateGraph];

    return cell;
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tv deselectRowAtIndexPath:indexPath animated:NO];
	
    int count = [mReports.reportEntries count];
    ReportEntry *re = (mReports.reportEntries)[count - indexPath.row - 1];

    CatReportViewController *vc = [CatReportViewController new];
    vc.title = [self _reportTitle:re];
    vc.reportEntry = re;
    [self.navigationController pushViewController:vc animated:YES];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (IS_IPAD) return YES;
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
