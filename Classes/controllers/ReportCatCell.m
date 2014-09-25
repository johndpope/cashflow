// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */
// ReportCatCell.m

#import "CashFlow-Swift.h"

#import "ReportCatCell.h"
#import "DataModel.h"
#import "AppDelegate.h"

@implementation ReportCatCell
{
    IBOutlet UILabel *_nameLabel;
    IBOutlet UILabel *_valueLabel;
    IBOutlet UIView *_graphView;
}

+ (CGFloat)cellHeight
{
    //return 44;
    return 32;
}


- (NSString *)name
{
    return _nameLabel.text;
}

- (void)setName:(NSString *)name
{
    _nameLabel.text = name;
}

- (void)setValue:(double)value maxValue:(double)maxValue
{
    double ratio;
    ratio = value / maxValue;
    if (ratio < 0) ratio = -ratio; // fail safe...
    if (ratio > 1.0) ratio = 1.0;
    
    _valueLabel.text = [NSString stringWithFormat:@"%@ (%.1f%%)",
                        [CurrencyManager formatCurrency:value],
                        ratio * 100.0, nil];
    if (value >= 0) {
        _valueLabel.textColor = [UIColor blackColor];
        _graphView.backgroundColor = [UIColor blueColor];
    } else {
        _valueLabel.textColor = [UIColor blackColor];
        _graphView.backgroundColor = [UIColor redColor];        
    }

    int fullWidth;
    if (IS_IPAD) {
        fullWidth = 500;
    } else {
        fullWidth = 190;
    }

    int width = fullWidth * ratio + 1;

    CGRect frame = _graphView.frame;
    frame.size.width = width;
    _graphView.frame = frame;
}

- (void)setGraphColor:(UIColor *)color
{
    _graphView.backgroundColor = color;
}

@end
