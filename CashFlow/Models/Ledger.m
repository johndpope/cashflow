// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

// Ledger : 総勘定元帳

#import "DataModel.h"
#import "Ledger.h"

@implementation Ledger

- (void)load
{
    self.assets = [Asset find_all:@"ORDER BY sorder"];
}

- (void)rebuild
{
    for (Asset *as in self.assets) {
        [as rebuild];
    }
}

- (NSInteger)assetCount
{
    return [self.assets count];
}

- (Asset*)assetAtIndex:(NSInteger)n
{
    return self.assets[n];
}

- (Asset*)assetWithKey:(NSInteger)pid
{
    for (Asset *as in self.assets) {
        if (as.pid == pid) return as;
    }
    return nil;
}

- (NSInteger)assetIndexWithKey:(NSInteger)pid
{
    int i;
    for (i = 0; i < [self.assets count]; i++) {
        Asset *as = self.assets[i];
        if (as.pid == pid) return i;
    }
    return -1;
}

- (void)addAsset:(Asset *)as
{
    [self.assets addObject:as];
    [as save];
}

- (void)deleteAsset:(Asset *)as
{
    [as delete];

    [[DataModel journal] deleteAllTransactionsWithAsset:as];

    [self.assets removeObject:as];

    [self rebuild];
}

- (void)updateAsset:(Asset*)asset
{
    [asset save];
}

- (void)reorderAsset:(NSInteger)from to:(NSInteger)to
{
    Asset *as = self.assets[from];
    [self.assets removeObjectAtIndex:from];
    [self.assets insertObject:as atIndex:to];
	
    // renumbering sorder
    Database *db = [Database instance];
    [db beginTransaction];
    for (NSInteger i = 0; i < [self.assets count]; i++) {
        as = self.assets[i];
        as.sorder = i;
        [as save];
    }
    [db commitTransaction];
}

@end
