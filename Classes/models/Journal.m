// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

// 仕訳帳

#import "AppDelegate.h"
#import "DataModel.h"
#import "Journal.h"
#import "CashflowDatabase.h"

@interface Journal()
- (void)_sortByDate;
@end

@implementation Journal

- (id)init
{
    self = [super init];
    if (self) {
        _entries = nil;
    }
    return self;
}


- (void)reload
{
    _entries = [Transaction find_all:@"ORDER BY date, key"];
    
    // upgrade data
    CashflowDatabase *db = (CashflowDatabase *)[Database instance];
    if (db.needFixDateFormat) {
        [self _sortByDate];
        
        [db beginTransaction];
        for (Transaction *t in _entries) {
            [t updateWithoutUpdateLRU];
        }
        [db commitTransaction];
    }
}

/**
   NSFastEnumeration protocol
*/
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])stackbuf count:(NSUInteger)len
{
    return [_entries countByEnumeratingWithState:state objects:stackbuf count:len];
}

- (void)insertTransaction:(Transaction*)tr
{
    int i;
    int max = [_entries count];
    Transaction *t = nil;

    // 挿入位置を探す
    for (i = 0; i < max; i++) {
        t = _entries[i];
        if ([tr.date compare:t.date] == NSOrderedAscending) {
            break;
        }
    }

    // 挿入
    [_entries insertObject:tr atIndex:i];
    [tr save];

    // 上限チェック
    if ([_entries count] > MAX_TRANSACTIONS) {
        // 最も古い取引を削除する
        // Note: 初期残高を調整するため、Asset 側で削除させる
        Transaction *t = _entries[0];
        Asset *asset = [[DataModel ledger] assetWithKey:t.asset];
        [asset deleteEntryAt:0];
    }
}

- (void)replaceTransaction:(Transaction *)from withObject:(Transaction*)to
{
    // copy key
    to.pid = from.pid;

    // update DB
    [to save];

    int idx = [_entries indexOfObject:from];
    _entries[idx] = to;
    [self _sortByDate];
}

// sort
static int compareByDate(Transaction *t1, Transaction *t2, void *context)
{
    return [t1.date compare:t2.date];
}
    
- (void)_sortByDate
{
    [_entries sortUsingFunction:compareByDate context:NULL];
}
    
/**
   Transaction 削除処理

   資産間移動取引の場合は、相手方資産残高が狂わないようにするため、
   相手方資産の入金・出金処理に置換する。

   @param t 取引
   @param asset 取引を削除する資産
   @return エントリが消去された場合は YES、置換された場合は NO。
*/
- (BOOL)deleteTransaction:(Transaction *)t withAsset:(Asset *)asset
{
    if (t.type != TYPE_TRANSFER) {
        // 資産間移動取引以外の場合
        [t delete];
        [_entries removeObject:t];
        return YES;
    }

    // 資産間移動の場合の処理
    // 通常取引 (入金 or 出金) に変更する
    if (t.asset == asset.pid) {
        // 自分が移動元の場合、移動方向を逆にする
        // (金額も逆転する）
        t.asset = t.dstAsset;
        t.value = -t.value;
    }
    t.dstAsset = -1;

    // 取引タイプを変更
    if (t.value >= 0) {
        t.type = TYPE_INCOME;
    } else {
        t.type = TYPE_OUTGO;
    }

    // データベース書き換え
    [t save];
    return NO;
}

/**
   Asset に紐づけられた全 Transaction を削除する (Asset 削除用)
*/
- (void)deleteAllTransactionsWithAsset:(Asset *)asset
{
    Transaction *t;
    int max = [_entries count];

    for (int i = 0; i < max; i++) {
        t = _entries[i];
        if (t.asset != asset.pid && t.dstAsset != asset.pid) {
            continue;
        }

        if ([self deleteTransaction:t withAsset:asset]) {
            // エントリが削除された場合は、配列が一個ずれる
            i--;
            max--;
        }
    }

    // rebuild が必要!
}

@end
