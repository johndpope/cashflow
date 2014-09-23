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
@property(nonatomic,assign) NSInteger dateTimeMode;

// 週の開始日 : 日曜 - 0, 月曜 - 1
@property(nonatomic,assign) NSInteger startOfWeek;

// 締め日 (1～29)、月末を指定する場合は 0
@property(nonatomic,assign) NSInteger cutoffDate;

// 最後に選択されたレポート種別 (REPORT_DAILY/WEEKLY/MONTHLY/ANNUAL/...)
@property(nonatomic,assign) NSInteger lastReportType;

+ (Config *)instance;
- (void)save;

@end
