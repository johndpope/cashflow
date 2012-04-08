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
@interface Report : NSObject

/** レポート種別 (REPORT_XXX) */
@property(nonatomic,assign) int type;
/** 期間毎の ReportEntry の配列 */
@property(nonatomic,strong) NSMutableArray *reportEntries;

- (void)generate:(int)type asset:(Asset *)asset;
- (double)getMaxAbsValue;

@end

/**
   各期間毎のレポートエントリ
*/
@interface ReportEntry : NSObject

/** 期間開始日 */
@property(nonatomic,strong,readonly) NSDate *start;

/** 期間終了日 */
@property(nonatomic,strong,readonly) NSDate *end;

/** 期間内の総収入 */
@property(nonatomic,assign,readonly) double totalIncome;

/** 期間内の総支出 */
@property(nonatomic,assign,readonly) double totalOutgo;

/** 収入の最大値 */
@property(nonatomic,assign,readonly) double maxIncome;

/** 支出の最大値（絶対値の) */
@property(nonatomic,assign,readonly) double maxOutgo;

/** カテゴリ毎の収入レポート */
@property(nonatomic,strong,readonly) NSMutableArray *incomeCatReports;

/** カテゴリ毎の支出レポート */
@property(nonatomic,strong,readonly) NSMutableArray *outgoCatReports;

- (id)initWithAsset:(int)assetKey start:(NSDate *)start end:(NSDate *)end;

- (BOOL)addTransaction:(Transaction*)t;
- (void)sortAndTotalUp;

@end

/**
   レポート(カテゴリ毎)

   本エントリは、期間(ReportEntry)毎、カテゴリ毎に１つ生成
*/
@interface CatReport : NSObject

/** カテゴリ (-1 は未分類) */
@property(nonatomic,readonly) int category;

/** 資産キー (-1 の場合は指定なし) */
@property(nonatomic,readonly) int assetKey;

/** 該当カテゴリ内の金額合計 */
@property(nonatomic,readonly) double sum;

/** 本カテゴリに含まれる Transaction 一覧 */
@property(nonatomic,strong,readonly) NSMutableArray *transactions;

- (id)initWithCategory:(int)category withAsset:(int)assetKey;
- (void)addTransaction:(Transaction*)t;

- (NSString *)title;

@end
