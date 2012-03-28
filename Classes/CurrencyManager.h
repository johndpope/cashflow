// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>

@interface CurrencyManager : NSObject
{
    @private

    NSString *mBaseCurrency;
    NSArray *mCurrencies;

    NSNumberFormatter *mNumberFormatter;
}

@property(nonatomic,strong) NSString *baseCurrency;
@property(nonatomic,strong) NSArray *currencies;

+ (CurrencyManager *)instance;

+ (NSString *)systemCurrency;
+ (NSString *)formatCurrency:(double)value;

@end

