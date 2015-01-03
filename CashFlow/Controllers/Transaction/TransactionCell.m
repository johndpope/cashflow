// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "CashFlow-Swift.h"

#import "TransactionCell.h"
#import "DataModel.h"
#import "AppDelegate.h"

@implementation TransactionCell
{
    IBOutlet UILabel *_descLabel;
    IBOutlet UILabel *_dateLabel;
    IBOutlet UILabel *_valueLabel;
    IBOutlet UILabel *_balanceLabel;
}

+ (void)registerCell:(UITableView *)tableView
{
    UINib *nib = [UINib nibWithNibName:@"TransactionCell" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:@"TransactionCell"];
}

+ (TransactionCell *)transactionCell:(UITableView *)tableView forIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"TransactionCell";

    return [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    /*
    TransactionCell *cell = (TransactionCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        NSArray *ary = [[NSBundle mainBundle] loadNibNamed:@"TransactionCell" owner:nil options:nil];
        cell = (TransactionCell *)ary[0];
    }
    return cell;
    */
}


- (TransactionCell *)updateWithAssetEntry:(AssetEntry *)entry
{
    [self setDescriptionLabel:entry.transaction.desc];
    [self setDateLabel:entry.transaction.date];
    [self setValueLabel:entry.value];
    [self setBalanceLabel:entry.balance];
    return self;
}

- (TransactionCell *)updateAsInitialBalance:(double)initialBalance
{
    [self setDescriptionLabel:_L(@"Initial Balance")];
    [self setBalanceLabel:initialBalance];
    _valueLabel.text = @"";
    _dateLabel.text = @"";
    return self;
}
     

- (void)setDescriptionLabel:(NSString *)desc
{
    _descLabel.text = desc;
}

- (void)setDateLabel:(NSDate *)date
{
    _dateLabel.text = [[DataModel dateFormatter] stringFromDate:date];
}

- (void)setValueLabel:(double)value
{
    if (value >= 0) {
        _valueLabel.textColor = [UIColor blueColor];
    } else {
        value = -value;
        _valueLabel.textColor = [UIColor redColor];
    }
    _valueLabel.text = [CurrencyManager formatCurrency:value];
}

- (void)setBalanceLabel:(double)balance
{
    _balanceLabel.text = [NSString stringWithFormat:@"%@ %@", _L(@"Bal."),
                          [CurrencyManager formatCurrency:balance]];
}

- (void)clearValueLabel
{
    _valueLabel.text = @"";
}

- (void)clearDateLabel
{
    _dateLabel.text = @"";
}

- (void)clearBalanceLabel
{
    _balanceLabel.text = @"";
}

@end
