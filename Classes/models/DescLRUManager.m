// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "DescLRUManager.h"
#import "Transaction.h"

@implementation DescLRUManager

// 旧バージョンからの移行処理
// Transaction から DescLRU を生成する
+ (void)migrate
{
    NSMutableArray *ary;
    
    ary = [self getDescLRUs:-1];
    if ([ary count] > 0) {
        return;
    }
    
    // okay, we need to migrate...
    ary = [Transaction find_all:@"ORDER BY date DESC LIMIT 100"];
    for (Transaction *t in ary) {
        [self addDescLRU:t.desc category:t.category date:t.date];
    }
}

+ (void)addDescLRU:(NSString *)description category:(int)category
{
    NSDate *now = [NSDate new];
    [self addDescLRU:description category:category date:now];
}

+ (void)addDescLRU:(NSString *)desc category:(int)category date:(NSDate*)date
{
    if ([desc length] == 0) return;

    // find desc LRU from history
    DescLRU *lru = [DescLRU find_by_description:desc];

    if (lru == nil) {
        // create new LRU
        lru = [DescLRU new];
        lru.desc = desc;
    }
    lru.category = category;
    lru.lastUse = date;
    [lru save];
}

+ (NSMutableArray *)getDescLRUs:(int)category
{
    NSMutableArray *ary;

    if (category < 0) {
        // 全検索
        ary = [DescLRU find_all:@"ORDER BY lastUse DESC LIMIT 100"];
    } else {
        dbstmt *stmt = [DescLRU gen_stmt:@"WHERE category = ? ORDER BY lastUse DESC LIMIT 100"];
        [stmt bindInt:0 val:category];
        ary = [DescLRU find_all_stmt:stmt];
    }
    return ary;
}

#if 0
+ (void)gc
{
    NSMutableArray *ary = [DescLRU find:cond:@"ORDER BY lastUse DESC LIMIT 1 OFFSET 100"];
    if ([ary count] > 0) {
        DescLRU *lru = [ary objectAtIndex:0];
        dbstmt *stmt = [[Database instance] prepare:@"DELETE FROM DescLRUs WHERE lastUse < ?"];
        [stmt bindDate:0 val:lru.date];
        [stmt step];
    }
}
#endif

@end
