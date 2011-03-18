// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "ExportCsv.h"
#import "AppDelegate.h"

@implementation ExportCsv

- (NSString *)mailSubject
{
    return "CashFlow CSV Data";
}

- (NSString *)fileName
{
    return @"CashFlow.txt";
}

- (NSString *)mimeType
{
    return @"text/comma-separated-value"; // for email
}

- (NSString *)contentType
{
    return @"text/csv"; // for web server : TODO: use comma-separated-value?
}

- (NSData *)generateBody
{
    NSMutableString *data = [[[NSMutableString alloc] initWithCapacity:1024] autorelease];
    
    for (Asset *asset in mAssets) {
        if ([mAssets count] > 1) {
            // show asset name
            [data appendString:asset.name];
            [data appendString:@"\n"];
        }
        [data appendString:@"Serial,Date,Value,Balance,Description,Category,Memo\n"];
    
        int max = [asset entryCount];

        /* トランザクション */
        int i = 0;
        if (mFirstDate != nil) {
            i = [asset firstEntryByDate:mFirstDate];
            if (i < 0) {
                return nil;
            }
        }
        for (; i < max; i++) {
            AssetEntry *e = [asset entryAt:i];

            if (mFirstDate != nil && [e.transaction.date compare:mFirstDate] == NSOrderedAscending) continue;
            
            NSMutableString *d = [[NSMutableString alloc] init];
            [d appendFormat:@"%d,", e.transaction.pid];
            [d appendFormat:@"%@,", [[DataModel dateFormatter] stringFromDate:e.transaction.date]];
            [d appendFormat:@"%.2f,", e.value];
            [d appendFormat:@"%.2f,", e.balance];
            [d appendFormat:@"%@,", e.transaction.description];
            [d appendFormat:@"%@,", [[DataModel instance].categories categoryStringWithKey:e.transaction.category]];
            [d appendFormat:@"%@", e.transaction.memo];
            [d appendString:@"\n"];
            [data appendString:d];
            [d release];
        }
        [data appendString:@"\n"];
    }

    // locale 毎の encoding を決める
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSString *lang = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
    if ([lang isEqualToString:@"ja"]) {
        // 日本語の場合は Shift-JIS にする
        encoding = NSShiftJISStringEncoding;
    }

    // バイナリ列に変換
    NSMutableData *d = [NSMutableData dataWithLength:0];
    const char *p = [data cStringUsingEncoding:encoding];
    if (!p) {
        encoding = NSUTF8StringEncoding;
        p = [data UTF8String]; // fallback
    }
    if (encoding == NSUTF8StringEncoding) {
        // UTF-8 BOM を追加
        const unsigned char bom[3] = {0xEF, 0xBB, 0xBF};
        [d appendBytes:bom length:sizeof(bom)];
    }
    [d appendBytes:p length:strlen(p)];

    return d;
}

@end
