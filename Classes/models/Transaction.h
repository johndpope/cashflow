// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import "TransactionBase.h"

#define TYPE_OUTGO      0       // 支払
#define TYPE_INCOME	1       // 入金
#define	TYPE_ADJ        2       // 残高調整
#define TYPE_TRANSFER   3       // 資産間移動

@class Asset;

@interface Transaction : TransactionBase <NSCopying>

// for balance adjustment
@property(nonatomic,assign) BOOL hasBalance;
@property(nonatomic,assign) double balance;

- (id)initWithDate:(NSDate*)date description:(NSString*)desc value:(double)v;
- (void)updateWithoutUpdateLRU;

+ (NSDate *)lastUsedDate;
+ (void)setLastUsedDate:(NSDate *)date;

@end
