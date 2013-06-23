// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "AppDelegate.h"
#import "Report.h"
#import "Database.h"
#import "Config.h"

@interface ReportEntry()
- (double)_sortAndTotalUp:(NSMutableArray*)array;
@end

@implementation ReportEntry
{
    /** 資産キー */
    int _assetKey;
}

static int sortCatReport(id x, id y, void *context);

/**
   イニシャライザ
 
   @param assetKey 資産キー (-1の場合は全資産)
   @param start 開始日
   @param end 終了日
 */
- (id)initWithAsset:(int)assetKey start:(NSDate *)start end:(NSDate *)end
{
    self = [super init];
    if (self == nil) return nil;

    _assetKey = assetKey;
    _start = start;
    _end = end;

    _totalIncome = 0.0;
    _totalOutgo = 0.0;

    // カテゴリ毎のレポート (CatReport) の生成
    Categories *categories = [DataModel instance].categories;
    int numCategories = [categories count];

    _incomeCatReports = [[NSMutableArray alloc] initWithCapacity:numCategories + 1];
    _outgoCatReports  = [[NSMutableArray alloc] initWithCapacity:numCategories + 1];

    for (int i = -1; i < numCategories; i++) {
        int catkey;
        CatReport *cr;

        if (i == -1) {
            catkey = -1; // 未分類項目用
        } else {
            catkey = [categories categoryAtIndex:i].pid;
        }

        cr = [[CatReport alloc] initWithCategory:catkey withAsset:assetKey];
        [_incomeCatReports addObject:cr];

        cr = [[CatReport alloc] initWithCategory:catkey withAsset:assetKey];
        [_outgoCatReports addObject:cr];
    }

    return self;
}


/**
   取引をレポートに追加

   @return NO - 日付範囲外, YES - 日付範囲ない、もしくは処理必要なし
*/
- (BOOL)addTransaction:(Transaction *)t
{
    // 資産 ID チェック
    double value;
    if (_assetKey < 0) {
        // 資産指定なしレポートの場合、資産間移動は計上しない
        if (t.type == TYPE_TRANSFER) return YES;
        value = t.value;
    } else if (t.asset == _assetKey) {
        // 通常または移動元
        value = t.value;        
    } else if (t.dstAsset == _assetKey) {
        // 移動先
        value = -t.value;
    } else {
        // 対象外
        return YES;
    }

    // 日付チェック
    NSComparisonResult cpr;
    if (_start) {
        cpr = [t.date compare:_start];
        if (cpr == NSOrderedAscending) return NO;
    }
    if (_end) {
        cpr = [t.date compare:_end];
        if (cpr == NSOrderedSame || cpr == NSOrderedDescending) {
            return NO;
        }
    }

    // 該当カテゴリを検索して追加
    NSMutableArray *ary;
    if (value < 0) {
        ary = _outgoCatReports;
    } else {
        ary = _incomeCatReports;
    }
    for (CatReport *cr in ary) {
        if (cr.category == t.category) {
            [cr addTransaction:t];
            break;
        }
    }
    return YES;
}

/**
   ソートと集計
*/
- (void)sortAndTotalUp
{
    _totalIncome = [self _sortAndTotalUp:_incomeCatReports];
    _totalOutgo  = [self _sortAndTotalUp:_outgoCatReports];
    
    _maxIncome = _maxOutgo = 0;
    CatReport *cr;
    if ([_incomeCatReports count] > 0) {
        cr = _incomeCatReports[0];
        _maxIncome = cr.sum;
    }
    if ([_outgoCatReports count] > 0) {
        cr = _outgoCatReports[0];
        _maxOutgo = cr.sum;
    }
}

- (double)_sortAndTotalUp:(NSMutableArray *)ary
{		
    // 金額が 0 のエントリを削除する
    int count = [ary count];
    for (int i = 0; i < count; i++) {
        CatReport *cr = ary[i];
        if (cr.sum == 0.0) {
            [ary removeObjectAtIndex:i];
            i--;
            count--;
        }
    }

    // ソート
    [ary sortUsingFunction:sortCatReport context:nil];

    // 集計
    double total = 0.0;
    for (CatReport *cr in ary) {
        total += cr.sum;
    }
    return total;
}

/**
   CatReport 比較用関数 : 絶対値降順でソート
*/
static int sortCatReport(id x, id y, void *context)
{
    CatReport *xr = (CatReport *)x;
    CatReport *yr = (CatReport *)y;

    double xv = xr.sum;
    double yv = yr.sum;
    if (xv < 0) xv = -xv;
    if (yv < 0) yv = -yv;
	
    if (xv == yv) {
        return NSOrderedSame;
    }
    if (xv > yv) {
        return NSOrderedAscending;
    }
    return NSOrderedDescending;
}

@end
