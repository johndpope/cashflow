// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */
//  TransactionCell.h

#import <UIKit/UIKit.h>
#import "AssetEntry.h"

@interface TransactionCell : UITableViewCell

+ (TransactionCell *)transactionCell:(UITableView *)tableView;

//- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier;
- (TransactionCell *)updateWithAssetEntry:(AssetEntry *)entry;
- (TransactionCell *)updateAsInitialBalance:(double)initialBalance;

- (void)setDescriptionLabel:(NSString *)desc;
- (void)setDateLabel:(NSDate *)date;
- (void)setValueLabel:(double)value;
- (void)setBalanceLabel:(double)balance;
- (void)clearValueLabel;
- (void)clearDateLabel;
- (void)clearBalanceLabel;

@end
