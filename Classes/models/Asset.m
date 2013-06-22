// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

// Asset

#import "AppDelegate.h"
#import "Asset.h"
#import "DataModel.h"

@interface Asset()
- (void)_deleteEntryAt:(int)n;
@end

@implementation Asset
{
    NSMutableArray *mEntries; // AssetEntry の配列
    //double mLastBalance;
}

+ (int)numAssetTypes
{
    return NUM_ASSET_TYPES;
}

+ (NSArray*)typeNamesArray
{
    static NSArray *typeNames = nil;

    if (typeNames == nil) {
        typeNames = 
            @[_L(@"Cash"),
                             _L(@"Bank Account"),
                             _L(@"Credit Card"),
                             _L(@"Investment Account"),
                             _L(@"Electric Money"),
];
    }
    return typeNames;
}

+ (NSString*)typeNameWithType:(int)type
{
    NSArray *typeNames = [Asset typeNamesArray];

    if (type < 0 || type >= [typeNames count]) {
        NSLog(@"WARNING: typeNameWithType: type out of range");
        return @"???";
    }
    return typeNames[type];
}

+ (NSString*)iconNameWithType:(int)type
{
    switch (type) {
        case ASSET_CASH:
            return @"cash";
        case ASSET_BANK:
            return @"bank";
        case ASSET_CARD:
            return @"card";
        case ASSET_INVEST:
            return @"invest";
        case ASSET_EMONEY:
            return @"cash";
            //return @"emoney";
    }

    ASSERT(NO);
    return nil; // ERROR!
}

- (id)init
{
    self = [super init];
    
    mEntries = [[NSMutableArray alloc] init];
    mType = ASSET_CASH;
	
    return self;
}


//
// 仕訳帳(journal)から転記しなおす
//
- (void)rebuild
{

    mEntries = [[NSMutableArray alloc] init];

    double balance = mInitialBalance;

    AssetEntry *e;
    for (Transaction *t in [DataModel journal]) {
        if (t.asset == self.pid || t.dstAsset == self.pid) {
            e = [[AssetEntry alloc] initWithTransaction:t withAsset:self];

            // 残高計算
            if (t.type == TYPE_ADJ && t.hasBalance) {
                // 残高から金額を逆算
                double oldval = t.value;
                t.value = t.balance - balance;
                if (t.value != oldval) {
                    // 金額が変更された場合、DBを更新
                    [t save];
                }
                balance = t.balance;

                e.value = t.value;
                e.balance = balance;
            }
            else {
                balance = balance + e.value;
                e.balance = balance;

                if (t.type == TYPE_ADJ) {
                    t.balance = balance;
                    t.hasBalance = YES;
                }
            }

            [mEntries addObject:e];
        }
    }

    //mLastBalance = balance;
}

- (void)updateInitialBalance
{
    [self save];
}

////////////////////////////////////////////////////////////////////////////
// AssetEntry operations

- (int)entryCount
{
    return mEntries.count;
}

- (AssetEntry*)entryAt:(int)n
{
    return mEntries[n];
}

- (void)insertEntry:(AssetEntry *)e
{    
    [[DataModel journal] insertTransaction:e.transaction];
    [[DataModel ledger] rebuild];
}

- (void)replaceEntryAtIndex:(int)index withObject:(AssetEntry *)e
{
    AssetEntry *orig = [self entryAt:index];

    [[DataModel journal] replaceTransaction:orig.transaction withObject:e.transaction];
    [[DataModel ledger] rebuild];
}

// エントリ削除
// 注：entries からは削除されない。journal から削除されるだけ
- (void)_deleteEntryAt:(int)index
{
    // 先頭エントリ削除の場合は、初期残高を変更する
    if (index == 0) {
        mInitialBalance = [[self entryAt:0] balance];
        [self updateInitialBalance];
    }

    // エントリ削除
    AssetEntry *e = [self entryAt:index];
    [[DataModel journal] deleteTransaction:e.transaction withAsset:self];
}

// エントリ削除
- (void)deleteEntryAt:(int)index
{
    [self _deleteEntryAt:index];
    
    // 転記し直す
    [[DataModel ledger] rebuild];
}

// 指定日以前の取引をまとめて削除
- (void)deleteOldEntriesBefore:(NSDate*)date
{
    Database *db = [Database instance];

    [db beginTransaction];
    while (mEntries.count > 0) {
        AssetEntry *e = mEntries[0];
        if ([e.transaction.date compare:date] != NSOrderedAscending) {
            break;
        }

        [self _deleteEntryAt:0];
        [mEntries removeObjectAtIndex:0];
    }
    [db commitTransaction];

    [[DataModel ledger] rebuild];
}

- (int)firstEntryByDate:(NSDate*)date
{
    for (int i = 0; i < mEntries.count; i++) {
        AssetEntry *e = mEntries[i];
        if ([e.transaction.date compare:date] != NSOrderedAscending) {
            return i;
        }
    }
    return -1;
}

////////////////////////////////////////////////////////////////////////////
// Balance operations

- (double)lastBalance
{
    int max = [mEntries count];
    if (max == 0) {
        return mInitialBalance;
    }
    return [mEntries[max - 1] balance];
}

//
// Database operations
//
+ (BOOL)migrate
{
    BOOL ret = [super migrate];
    
    if (ret) {
        // newly created...
        Asset *as = [[Asset alloc] init];
        as.name = _L(@"Cash");
        as.type = ASSET_CASH;
        as.initialBalance = 0;
        as.sorder = 0;
        [as save];
    }
    return ret;
}

@end
