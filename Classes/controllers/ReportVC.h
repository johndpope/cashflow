// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */
//  ReportViewController.h

#import <UIKit/UIKit.h>
#import "Report.h"
#import "Asset.h"

@interface ReportViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>
{
    IBOutlet UITableView *mTableView;

    int mType;
    Asset *mDesignatedAsset;
    Report *mReports;
    double mMaxAbsValue;

    NSDateFormatter *mDateFormatter;
}

@property(nonatomic,retain) UITableView *tableView;
@property(nonatomic,retain) Asset *designatedAsset;

- (id)initWithAsset:(Asset*)asset type:(int)type;    // designated initializer
- (id)initWithAsset:(Asset*)asset; 

- (IBAction)setReportDaily:(id)sender;
- (IBAction)setReportWeekly:(id)sender;
- (IBAction)setReportMonthly:(id)sender;
- (IBAction)setReportAnnual:(id)sender;

@end
