// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */
//  ReportCatCell.h

#import <UIKit/UIKit.h>
#import "Report.h"

@class GraphEntry;

@interface ReportCatGraphCell : UITableViewCell

+ (CGFloat)cellHeight;
+ (UIColor *)getGraphColor:(NSInteger)index;

- (void)setReport:(ReportEntry *)reportEntry isOutgo:(BOOL)isOutgo;

@end
