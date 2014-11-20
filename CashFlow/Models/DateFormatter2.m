// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "DateFormatter2.h"

@implementation DateFormatter2

- (id)init
{
    self = [super init];

    // JP locale では特に 12時間制のときの日付フォーマットがおかしいので、
    // US locale にする
    [self setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"US"]];
    return self;
}

// 12時間制になってしまっているデータを強制的に変換する
- (NSString *)fixDateString:(NSString *)string
{
    int hoffset = 0;
    NSRange range;
    BOOL needFix = NO;

    //NSLog(@"Prev: %@", string);
    // "午前"はそのまま削除
    range = [string rangeOfString:@"午前"];
    if (range.location != NSNotFound) {
        needFix = YES;
        hoffset = 0;
    } else {
        range = [string rangeOfString:@"午後"];
        if (range.location != NSNotFound) {
            needFix = YES;
            hoffset = 12;
        }
    }

    if (needFix) {
        // 時刻を取り出す
        NSRange hrange = range;
        hrange.location += range.length;
        hrange.length = 2;
        int hour = [[string substringWithRange:hrange] intValue];

        // 時刻を調整
        if (hour == 12) {
            // 午前12時 ⇒ 0時、午後12時 ⇒ 12時
            hour = 0;
        }
        hour += hoffset;
        NSString *hstr = [NSString stringWithFormat:@"%02d", hour];

        // 文字列を置換
        range.length += 2;
        string = [string stringByReplacingCharactersInRange:range withString:hstr];
    }

    //NSLog(@"After: %@", string);
    return string;
}

- (NSDate *)dateFromString:(NSString *)string
{
    return [super dateFromString:[self fixDateString:string]];
}

@end
