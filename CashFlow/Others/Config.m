// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "Config.h"

@implementation Config

#define KEY_DATE_TIME_MODE @"DateTimeMode"
#define KEY_START_OF_WEEK @"StartOfWeek"
#define KEY_CUTOFF_DATE @"CutoffDate"
#define KEY_LAST_REPORT_TYPE @"LastReportType"
#define KEY_USE_TOUCH_ID @"UseTouchId"

static Config *sConfig = nil;

+ (Config *)instance
{
    if (!sConfig) {
        sConfig = [Config new];
    }
    return sConfig;
}

- (id)init
{
    self = [super init];
    if (!self) return nil;


    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];    
    
    _dateTimeMode = [defaults integerForKey:KEY_DATE_TIME_MODE];
    if (_dateTimeMode != DateTimeModeDateOnly &&
        _dateTimeMode != DateTimeModeWithTime &&
        _dateTimeMode != DateTimeModeWithTime5min) {
        _dateTimeMode = DateTimeModeWithTime;
    }

    _startOfWeek = [defaults integerForKey:KEY_START_OF_WEEK];
    
    _cutoffDate = [defaults integerForKey:KEY_CUTOFF_DATE];
    if (_cutoffDate < 0 || _cutoffDate > 28) {
        _cutoffDate = 0;
    }

    _lastReportType = [defaults integerForKey:KEY_LAST_REPORT_TYPE];

    _useTouchId = [defaults boolForKey:KEY_USE_TOUCH_ID];
    
    // 初期処理
    if (!_useTouchId) {
        if ([defaults objectForKey:KEY_USE_TOUCH_ID] == nil) {
            _useTouchId = YES;
            [defaults setBool:_useTouchId forKey:KEY_USE_TOUCH_ID];
            [defaults synchronize];
        }
    }
    return self;
}

- (void)save
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults setInteger:_dateTimeMode forKey:KEY_DATE_TIME_MODE];
    [defaults setInteger:_startOfWeek forKey:KEY_START_OF_WEEK];
    [defaults setInteger:_cutoffDate forKey:KEY_CUTOFF_DATE];
    [defaults setInteger:_lastReportType forKey:KEY_LAST_REPORT_TYPE];
    [defaults setBool:_useTouchId forKey:KEY_USE_TOUCH_ID];

    [defaults synchronize];
}

@end
