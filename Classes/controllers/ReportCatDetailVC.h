// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */
//  ReportCatDetailVC.h

#import <UIKit/UIKit.h>
#import "Report.h"

@interface CatReportDetailViewController : UITableViewController
{
    CatReport *mCatReport;
}

@property(nonatomic,strong) CatReport *catReport;

- (void)doneAction:(id)sender;

@end
