// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */
// ReportCell.m

#import "ReportCell.h"
#import "DataModel.h"
#import "AppDelegate.h"

@implementation ReportCell

@synthesize name = mName, income = mIncome, outgo = mOutgo, maxAbsValue = mMaxAbsValue;

+ (ReportCell *)reportCell:(UITableView *)tableView
{
    NSString *identifier = @"ReportCell";

    ReportCell *cell = (ReportCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        NSArray *ary = [[NSBundle mainBundle] loadNibNamed:@"ReportCell" owner:nil options:nil];
        cell = (ReportCell *)[ary objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

+ (CGFloat)cellHeight
{
    return 44; // 62
}

- (void)dealloc {
    [mName release];
    [super dealloc];
}

- (void)setName:(NSString *)n
{
    if (mName == n) return;

    [mName release];
    mName = [n retain];

    mNameLabel.text = mName;
}

- (void)setIncome:(double)v
{
    mIncome = v;
    mIncomeLabel.text = [CurrencyManager formatCurrency:mIncome];
}

- (void)setOutgo:(double)v
{
    mOutgo = v;
    mOutgoLabel.text = [CurrencyManager formatCurrency:mOutgo];
}

- (void)setMaxAbsValue:(double)mav
{
    mMaxAbsValue = mav;
    if (mMaxAbsValue < 0.0000001) {
        mMaxAbsValue = 0.0000001; // for safety
    }
}

- (void)updateGraph
{
    double ratio;
    int fullWidth;
    
    if (IS_IPAD) {
        fullWidth = 500;
    } else {
        fullWidth = 170;
    }

    ratio = mIncome / mMaxAbsValue;
    if (ratio > 1.0) ratio = 1.0;

    CGRect frame = mIncomeGraph.frame;
    frame.size.width = fullWidth * ratio + 1;
    mIncomeGraph.frame = frame;

    ratio = -mOutgo / mMaxAbsValue;
    if (ratio > 1.0) ratio = 1.0;
    
    frame = mOutgoGraph.frame;
    frame.size.width = fullWidth * ratio + 1;
    mOutgoGraph.frame = frame;
}

@end
