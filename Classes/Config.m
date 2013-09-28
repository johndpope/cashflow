// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "Config.h"

@implementation Config

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
    
    _dateTimeMode = [defaults integerForKey:@"DateTimeMode"];
    if (_dateTimeMode != DateTimeModeDateOnly &&
        _dateTimeMode != DateTimeModeWithTime &&
        _dateTimeMode != DateTimeModeWithTime5min) {
        _dateTimeMode = DateTimeModeWithTime;
    }

    _startOfWeek = [defaults integerForKey:@"StartOfWeek"];
    
    _cutoffDate = [defaults integerForKey:@"CutoffDate"];
    if (_cutoffDate < 0 || _cutoffDate > 28) {
        _cutoffDate = 0;
    }

    _lastReportType = [defaults integerForKey:@"LastReportType"];
    return self;
}

- (void)save
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults setInteger:_dateTimeMode forKey:@"DateTimeMode"];
    [defaults setInteger:_startOfWeek forKey:@"StartOfWeek"];
    [defaults setInteger:_cutoffDate forKey:@"CutoffDate"];
    [defaults setInteger:_lastReportType forKey:@"LastReportType"];

    [defaults synchronize];
}

@end
