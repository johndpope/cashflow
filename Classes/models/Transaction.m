// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "Transaction.h"
#import "Database.h"
#import "Config.h"
#import "DescLRUManager.h"

@implementation Transaction

@synthesize hasBalance = mHasBalance;
@synthesize balance = mBalance;

/*
 */
+ (BOOL)migrate
{
    BOOL ret = [super migrate];
    return ret;
}

- (id)init
{
    self = [super init];

    self.asset = -1;
    self.dstAsset = -1;
    
    // 現在時刻で作成
    NSDate *dt = [[[NSDate alloc] init] autorelease];
    
    if ([Config instance].dateTimeMode == DateTimeModeDateOnly) {
        // 時刻を 0:00:00 に設定
        NSCalendar *greg = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
        NSDateComponents *dc = [greg components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:dt];
        dt = [greg dateFromComponents:dc];
    }
    
    self.date = dt;
    self.description = @"";
    self.memo = @"";
    self.value = 0.0;
    self.type = 0;
    self.category = -1;
    self.hasBalance = NO;
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (id)initWithDate: (NSDate*)dt description:(NSString*)desc value:(double)v
{
    self = [super init];

    self.asset = -1;
    self.dstAsset = -1;
    self.date = dt;
    self.description = desc;
    self.memo = @"";
    self.value = v;
    self.type = 0;
    self.category = -1;
    self.pid = 0; // init
    self.hasBalance = NO;
    return self;
}

- (id)copyWithZone:(NSZone*)zone
{
    Transaction *n = [[Transaction alloc] init];
    n.pid = self.pid;
    n.asset = self.asset;
    n.dstAsset = self.dstAsset;
    n.date = self.date;
    n.description = self.description;
    n.memo = self.memo;
    n.value = self.value;
    n.type = self.type;
    n.category = self.category;
    n.hasBalance = self.hasBalance;
    n.balance = self.balance;
    return n;
}

- (void)_insert
{
    [super _insert];
    [DescLRUManager addDescLRU:self.description category:self.category];
}

- (void)_update
{
    [super _update];
    [DescLRUManager addDescLRU:self.description category:self.category];
}

- (void)updateWithoutUpdateLRU
{
    [super _update];
}

@end
