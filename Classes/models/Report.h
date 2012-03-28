// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import "Transaction.h"
#import "DataModel.h"

#define REPORT_DAILY 0
#define REPORT_WEEKLY 1
#define REPORT_MONTHLY 2
#define REPORT_ANNUAL 3

#define MAX_REPORT_ENTRIES      365

/*
  レポートの構造

  Report -> ReportEntry -> CatReport
 */

/**
   レポート
*/
@interface Report : NSObject {
    @private
    /** レポート種別 (REPORT_XXX) */
    int mType;

    /** 期間毎の ReportEntry の配列 */
    NSMutableArray *mReportEntries;
}

@property(nonatomic,assign) int type;
@property(nonatomic,strong) NSMutableArray *reportEntries;

- (void)generate:(int)type asset:(Asset *)asset;
- (double)getMaxAbsValue;

@end

/**
   各期間毎のレポートエントリ
*/
@interface ReportEntry : NSObject {
    @private

    /** 資産キー */
    int mAssetKey;
    
    /** 期間開始日 */
    NSDate *mStart;

    /** 期間終了日 */
    NSDate *mEnd;

    /** 期間内の総収入 */
    double mTotalIncome;

    /** 期間内の総支出 */
    double mTotalOutgo;
    
    /** 収入の最大値 */
    double mMaxIncome;
    
    /** 支出の最大値（絶対値の) */
    double mMaxOutgo;

    /** カテゴリ毎の収入レポート */
    NSMutableArray *mIncomeCatReports;

    /** カテゴリ毎の支出レポート */
    NSMutableArray *mOutgoCatReports;
}

@property(nonatomic,readonly) NSDate *start;
@property(nonatomic,readonly) NSDate *end;
@property(nonatomic,readonly) double totalIncome;
@property(nonatomic,readonly) double totalOutgo;
@property(nonatomic,readonly) double maxIncome;
@property(nonatomic,readonly) double maxOutgo;
@property(nonatomic,readonly) NSMutableArray *incomeCatReports;
@property(nonatomic,readonly) NSMutableArray *outgoCatReports;

- (id)initWithAsset:(int)assetKey start:(NSDate *)start end:(NSDate *)end;

- (BOOL)addTransaction:(Transaction*)t;
- (void)sortAndTotalUp;

@end

/**
   レポート(カテゴリ毎)

   本エントリは、期間(ReportEntry)毎、カテゴリ毎に１つ生成
*/
@interface CatReport : NSObject {
    @private

    /** カテゴリ (-1 は未分類) */
    int mCategory;
    
    /** 資産キー (-1 の場合は指定なし) */
    int mAssetKey;

    /** 該当カテゴリ内の金額合計 */
    double mSum;

    /** 本カテゴリに含まれる Transaction 一覧 */
    NSMutableArray *mTransactions;
}

@property(nonatomic,readonly) int category;
@property(nonatomic,readonly) int assetKey;
@property(nonatomic,readonly) double sum;
@property(nonatomic,readonly) NSMutableArray *transactions;

- (id)initWithCategory:(int)category withAsset:(int)assetKey;
- (void)addTransaction:(Transaction*)t;

- (NSString *)title;

@end
