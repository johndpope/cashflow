// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "AppDelegate.h"
#import "CashflowDatabase.h"

@implementation Database(cashflow)

+ (Database *)instance
{
    Database *db = [self _instance];
    if (db == nil) {
        db = [CashflowDatabase new];
        [self _setInstance:db];
    }
    return db;
}

@end

@implementation CashflowDatabase

@synthesize needFixDateFormat;

- (id)init
{
    self = [super init];
    
    needFixDateFormat = false;
	
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [dateFormatter setDateFormat: @"yyyyMMddHHmmss"];
    
    // Set US locale, because JP locale for date formatter is buggy,
    // especially for 12 hour settings.
    NSLocale *us = [[NSLocale alloc] initWithLocaleIdentifier:@"US"];
    [dateFormatter setLocale:us];

    // backward compat.
    dateFormatter2 = [[DateFormatter2 alloc] init];
    [dateFormatter2 setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [dateFormatter2 setDateFormat: @"yyyyMMddHHmm"];
    
    // for broken data...
    dateFormatter3 = [[DateFormatter2 alloc] init];
    [dateFormatter3 setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [dateFormatter3 setDateFormat: @"yyyyMMdd"];
    
    return self;
}


#pragma mark -
#pragma mark Utilities

// Override
- (NSDate *)dateFromString:(NSString *)str
{
    NSDate *date = nil;
    
    if ([str length] == 14) { // yyyyMMddHHmmss
        date = [dateFormatter dateFromString:str];
    }
    if (date == nil) {
        // backward compat.
        needFixDateFormat = true;
        date = [dateFormatter2 dateFromString:str];

        if (date == nil) {
            date = [dateFormatter3 dateFromString:str];
        }
        if (date == nil) {
            date = [dateFormatter dateFromString:@"20000101000000"]; // fallback
        }
    }
    return date;
}

// Override
- (NSString *)stringFromDate:(NSDate *)date
{
    NSString *str = [dateFormatter stringFromDate:date];
    return str;
}

@end
