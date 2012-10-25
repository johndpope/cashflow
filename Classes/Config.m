// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "Config.h"

@implementation Config

@synthesize dateTimeMode = mDateTimeMode;
@synthesize startOfWeek = mStartOfWeek;
@synthesize cutoffDate = mCutoffDate;
@synthesize lastReportType = mLastReportType;

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
    
    mDateTimeMode = [defaults integerForKey:@"DateTimeMode"];
    if (mDateTimeMode != DateTimeModeDateOnly &&
        mDateTimeMode != DateTimeModeWithTime &&
        mDateTimeMode != DateTimeModeWithTime5min) {
        mDateTimeMode = DateTimeModeWithTime;
    }

    mStartOfWeek = [defaults integerForKey:@"StartOfWeek"];
    
    mCutoffDate = [defaults integerForKey:@"CutoffDate"];
    if (mCutoffDate < 0 || mCutoffDate > 28) {
        mCutoffDate = 0;
    }

    mLastReportType = [defaults integerForKey:@"LastReportType"];
    return self;
}

- (void)save
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults setInteger:mDateTimeMode forKey:@"DateTimeMode"];
    [defaults setInteger:mStartOfWeek forKey:@"StartOfWeek"];
    [defaults setInteger:mCutoffDate forKey:@"CutoffDate"];
    [defaults setInteger:mLastReportType forKey:@"LastReportType"];

    [defaults synchronize];
}

@end
