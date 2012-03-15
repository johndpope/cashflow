// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

// sqlite3 wrapper

#import <UIKit/UIKit.h>
#import <sqlite3.h>

#import "DateFormatter2.h" // backward compat.
#import "Database.h"

@interface Database (cashflow)
@end


/**
   Wrapper class of sqlite3 database
*/
@interface CashflowDatabase : Database {
    @private
    NSDateFormatter *dateFormatter;
    DateFormatter2 *dateFormatter2;
    NSDateFormatter *dateFormatter3;
    
    BOOL needFixDateFormat;
}

@property(nonatomic,readonly) BOOL needFixDateFormat;

// utilities
- (NSDate*)dateFromString:(NSString *)str;
- (NSString *)stringFromDate:(NSDate*)date;

@end
