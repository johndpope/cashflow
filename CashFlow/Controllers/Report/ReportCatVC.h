// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */
//  ReportCatVC.h

#import <UIKit/UIKit.h>
#import "Report.h"

@interface CatReportViewController : UITableViewController

@property(nonatomic,strong) ReportEntry *reportEntry;

- (void)doneAction:(id)sender;

@end
