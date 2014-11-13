// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */
//  ReportCell.h

#import <UIKit/UIKit.h>

@interface ReportCell : UITableViewCell

@property(nonatomic,strong) NSString *name;
@property(nonatomic,assign) double income;
@property(nonatomic,assign) double outgo;
@property(nonatomic,assign) double maxAbsValue;

+ (CGFloat)cellHeight;

- (void)updateGraph;

@end
