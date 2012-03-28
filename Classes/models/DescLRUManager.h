// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "DescLRU.h"

@interface DescLRUManager : NSObject
+ (void)migrate;

+ (void)addDescLRU:(NSString *)description category:(int)category;
+ (void)addDescLRU:(NSString *)description category:(int)category date:(NSDate*)date;
+ (NSMutableArray *)getDescLRUs:(int)category;

@end


