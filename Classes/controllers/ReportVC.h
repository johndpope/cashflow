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

@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong) Asset *designatedAsset;

+ (ReportViewController *)instantiate;

- (void)setAsset:(Asset*)asset type:(int)type;
- (void)setAsset:(Asset*)asset;

@end
