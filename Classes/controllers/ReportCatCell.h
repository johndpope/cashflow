// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */
//  ReportCatCell.h

#import <UIKit/UIKit.h>

@interface ReportCatCell : UITableViewCell {
    IBOutlet UILabel *mNameLabel;
    IBOutlet UILabel *mValueLabel;
    IBOutlet UIView *mGraphView;
}

@property(nonatomic,strong) NSString *name;

+ (ReportCatCell *)reportCatCell:(UITableView *)tableView;
+ (CGFloat)cellHeight;

- (void)setValue:(double)value maxValue:(double)maxValue;
- (void)setGraphColor:(UIColor *)color;

@end
