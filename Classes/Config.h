// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>

@interface Config : NSObject

// 日時モード
#define DateTimeModeWithTime 0  // 日＋時
#define DateTimeModeWithTime5min 1  // 日＋時
#define DateTimeModeDateOnly 2  // 日のみ
@property(nonatomic,assign) int dateTimeMode;

// 週の開始日 : 日曜 - 0, 月曜 - 1
@property(nonatomic,assign) int startOfWeek;

// 締め日 (1～29)、月末を指定する場合は 0
@property(nonatomic,assign) int cutoffDate;

// 最後に選択されたレポート種別 (REPORT_DAILY/WEEKLY/MONTHLY/ANNUAL/...)
@property(nonatomic,assign) int lastReportType;

+ (Config *)instance;
- (void)save;

@end
