// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */
// ReportCell.m

#import "CashFlow-Swift.h"

#import "ReportCell.h"
#import "DataModel.h"
#import "AppDelegate.h"

@implementation ReportCell
{
    IBOutlet UILabel *_nameLabel;
    IBOutlet UILabel *_incomeLabel;
    IBOutlet UILabel *_outgoLabel;
    IBOutlet UIView *_incomeGraph;
    IBOutlet UIView *_outgoGraph;
}

+ (CGFloat)cellHeight
{
    return 44; // 62
}

- (void)setName:(NSString *)n
{
    if (_name == n) return;

    _name = n;

    _nameLabel.text = _name;
}

- (void)setIncome:(double)v
{
    _income = v;
    _incomeLabel.text = [CurrencyManager formatCurrency:_income];
}

- (void)setOutgo:(double)v
{
    _outgo = v;
    _outgoLabel.text = [CurrencyManager formatCurrency:_outgo];
}

- (void)setMaxAbsValue:(double)mav
{
    _maxAbsValue = mav;
    if (_maxAbsValue < 0.0000001) {
        _maxAbsValue = 0.0000001; // for safety
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

    ratio = _income / _maxAbsValue;
    if (ratio > 1.0) ratio = 1.0;

    CGRect frame = _incomeGraph.frame;
    frame.size.width = fullWidth * ratio + 1;
    _incomeGraph.frame = frame;

    ratio = -_outgo / _maxAbsValue;
    if (ratio > 1.0) ratio = 1.0;
    
    frame = _outgoGraph.frame;
    frame.size.width = fullWidth * ratio + 1;
    _outgoGraph.frame = frame;
}

@end
