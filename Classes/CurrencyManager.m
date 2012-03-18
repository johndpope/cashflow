// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2012, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "CurrencyManager.h"

@interface CurrencyManager()
- (NSString *)_formatCurrency:(double)value;
@end

@implementation CurrencyManager

@synthesize baseCurrency = mBaseCurrency;
@synthesize currencies = mCurrencies;

/**
 * CurrencyManager のインスタンスを返す
 */
+ (CurrencyManager *)instance
{
    static CurrencyManager *theInstance = nil;
    if (theInstance == nil) {
        theInstance = [[CurrencyManager alloc] init];
    }
    return theInstance;
}

- (id)init
{
    self = [super init];

    NSNumberFormatter *nf;

    nf = [[NSNumberFormatter alloc] init];
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    [nf setLocale:[NSLocale currentLocale]];
    mNumberFormatter = nf;

    self.currencies =
        [NSArray arrayWithObjects:
         @"AED",
         @"AUD",
         @"BHD",
         @"BND",
         @"BRL",
         @"CAD", 
         @"CHF",
         @"CLP",
         @"CNY",
         @"CYP",
         @"CZK",
         @"DKK",
         @"EUR",
         @"GBP",
         @"HKD",
         @"HUF",
         @"IDR",
         @"ILS",
         @"INR",
         @"ISK",
         @"JPY",
         @"KRW",
         @"KWD",
         @"KZT",
         @"LKR",
         @"MTL",
         @"MUR",
         @"MXN",
         @"MYR",
         @"NOK",
         @"NPR",
         @"NZD",
         @"OMR",
         @"PKR",
         @"QAR",
         @"RUB",
         @"SAR",
         @"SEK",
         @"SGD",
         @"SKK",
         @"THB",
         @"TWD",
         @"USD",
         @"ZAR",
         nil];

    self.baseCurrency = [[NSUserDefaults standardUserDefaults] objectForKey:@"BaseCurrency"];

    return self;
}

/**
 * システムデフォルトの通貨コードを返す
 */
+ (NSString *)systemCurrency
{
    NSNumberFormatter *nf = [NSNumberFormatter new];
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    return [nf currencyCode];
}

/**
 * ベース通貨コードを設定する
 */
- (void)setBaseCurrency:(NSString *)currency
{
    if (mBaseCurrency != currency) {
        mBaseCurrency = currency;
        
        if (currency == nil) {
            currency = [CurrencyManager systemCurrency];
        }
        [mNumberFormatter setCurrencyCode:currency];
        
        [[NSUserDefaults standardUserDefaults] setObject:mBaseCurrency forKey:@"BaseCurrency"];
    }
}

/**
 * 通貨を文字列にフォーマットする
 */
+ (NSString *)formatCurrency:(double)value
{
    return [[CurrencyManager instance] _formatCurrency:value];
}

- (NSString *)_formatCurrency:(double)value
{
    NSNumber *n = [NSNumber numberWithDouble:value];
    return [mNumberFormatter stringFromNumber:n];
}

@end
        

