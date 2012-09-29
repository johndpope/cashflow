// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "TransactionCell.h"
#import "DataModel.h"
#import "AppDelegate.h"
#import "CurrencyManager.h"

@implementation TransactionCell
{
    IBOutlet UILabel *mDescLabel;
    IBOutlet UILabel *mDateLabel;
    IBOutlet UILabel *mValueLabel;
    IBOutlet UILabel *mBalanceLabel;
}

+ (TransactionCell *)transactionCell:(UITableView *)tableView
{
    static NSString *identifier = @"TransactionCell";

    TransactionCell *cell = (TransactionCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        NSArray *ary = [[NSBundle mainBundle] loadNibNamed:@"TransactionCell" owner:nil options:nil];
        cell = (TransactionCell *)ary[0];
    }
    return cell;
}


- (TransactionCell *)updateWithAssetEntry:(AssetEntry *)entry
{
    [self setDescriptionLabel:entry.transaction.description];
    [self setDateLabel:entry.transaction.date];
    [self setValueLabel:entry.value];
    [self setBalanceLabel:entry.balance];
    return self;
}

- (TransactionCell *)updateAsInitialBalance:(double)initialBalance
{
    [self setDescriptionLabel:_L(@"Initial Balance")];
    [self setBalanceLabel:initialBalance];
    mValueLabel.text = @"";
    mDateLabel.text = @"";
    return self;
}
     

- (void)setDescriptionLabel:(NSString *)desc
{
    mDescLabel.text = desc;
}

- (void)setDateLabel:(NSDate *)date
{
    mDateLabel.text = [[DataModel dateFormatter] stringFromDate:date];
}

- (void)setValueLabel:(double)value
{
    if (value >= 0) {
        mValueLabel.textColor = [UIColor blueColor];
    } else {
        value = -value;
        mValueLabel.textColor = [UIColor redColor];
    }
    mValueLabel.text = [CurrencyManager formatCurrency:value];
}

- (void)setBalanceLabel:(double)balance
{
    mBalanceLabel.text = [NSString stringWithFormat:@"%@ %@", _L(@"Balance"), 
                          [CurrencyManager formatCurrency:balance]];
}

- (void)clearValueLabel
{
    mValueLabel.text = @"";
}

- (void)clearDateLabel
{
    mDateLabel.text = @"";
}

- (void)clearBalanceLabel
{
    mBalanceLabel.text = @"";
}

@end
