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
    int mAssetKey;
}

@synthesize start = mStart, end = mEnd;
@synthesize totalIncome = mTotalIncome, totalOutgo = mTotalOutgo;
@synthesize maxIncome = mMaxIncome, maxOutgo = mMaxOutgo;
@synthesize incomeCatReports = mIncomeCatReports, outgoCatReports = mOutgoCatReports;

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

    mAssetKey = assetKey;
    mStart = start;
    mEnd = end;

    mTotalIncome = 0.0;
    mTotalOutgo = 0.0;

    // カテゴリ毎のレポート (CatReport) の生成
    Categories *categories = [DataModel instance].categories;
    int numCategories = [categories count];

    mIncomeCatReports = [[NSMutableArray alloc] initWithCapacity:numCategories + 1];
    mOutgoCatReports  = [[NSMutableArray alloc] initWithCapacity:numCategories + 1];

    for (int i = -1; i < numCategories; i++) {
        int catkey;
        CatReport *cr;

        if (i == -1) {
            catkey = -1; // 未分類項目用
        } else {
            catkey = [categories categoryAtIndex:i].pid;
        }

        cr = [[CatReport alloc] initWithCategory:catkey withAsset:assetKey];
        [mIncomeCatReports addObject:cr];

        cr = [[CatReport alloc] initWithCategory:catkey withAsset:assetKey];
        [mOutgoCatReports addObject:cr];
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
    if (mAssetKey < 0) {
        // 資産指定なしレポートの場合、資産間移動は計上しない
        if (t.type == TYPE_TRANSFER) return YES;
        value = t.value;
    } else if (t.asset == mAssetKey) {
        // 通常または移動元
        value = t.value;        
    } else if (t.dstAsset == mAssetKey) {
        // 移動先
        value = -t.value;
    } else {
        // 対象外
        return YES;
    }

    // 日付チェック
    NSComparisonResult cpr;
    if (mStart) {
        cpr = [t.date compare:mStart];
        if (cpr == NSOrderedAscending) return NO;
    }
    if (mEnd) {
        cpr = [t.date compare:mEnd];
        if (cpr == NSOrderedSame || cpr == NSOrderedDescending) {
            return NO;
        }
    }

    // 該当カテゴリを検索して追加
    NSMutableArray *ary;
    if (value < 0) {
        ary = mOutgoCatReports;
    } else {
        ary = mIncomeCatReports;
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
    mTotalIncome = [self _sortAndTotalUp:mIncomeCatReports];
    mTotalOutgo  = [self _sortAndTotalUp:mOutgoCatReports];
    
    mMaxIncome = mMaxOutgo = 0;
    CatReport *cr;
    if ([mIncomeCatReports count] > 0) {
        cr = mIncomeCatReports[0];
        mMaxIncome = cr.sum;
    }
    if ([mOutgoCatReports count] > 0) {
        cr = mOutgoCatReports[0];
        mMaxOutgo = cr.sum;
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
