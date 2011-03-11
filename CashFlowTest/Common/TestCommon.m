// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import <UIKit/UIKit.h>
#import "TestCommon.h"

@implementation TestCommon

+ (DateFormatter2 *)dateFormatter
{
    static DateFormatter2 *df = nil;
    if (df == nil) {
        df = [[DateFormatter2 alloc] init];
        [df setTimeZone: [NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        [df setDateFormat: @"yyyyMMddHHmmss"];
    }
    return df;
}

+ (NSDate *)dateWithString:(NSString *)s
{
    return [[TestCommon dateFormatter] dateFromString:s];
}

+ (NSString *)stringWithDate:(NSDate *)date
{
    return [[TestCommon dateFormatter] stringFromDate:date];
}

// データベースを削除する
+ (void)deleteDatabase
{
    [DataModel finalize];

    NSString *dbPath = [[Database instance] dbPath:@"CashFlow.db"];

    if ([[NSFileManager defaultManager] removeItemAtPath:dbPath error:NULL]) {
        //NSLog(@"db removed: %@", dbPath);
    } else {
        //NSLog(@"deleteDatabase failed!: %@", dbPath);
    }

    [Database shutdown];
}

// データベースをインストールする
+ (BOOL)installDatabase:(NSString *)sqlFileName
{
    [TestCommon deleteDatabase];

    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    //NSString *sqlPath = [[NSBundle mainBundle] pathForResource:sqlFileName ofType:@"sql"];
    NSString *sqlPath = [bundle pathForResource:sqlFileName ofType:@"sql"];
    if (sqlPath == NULL) {
        NSLog(@"FATAL: no SQL data file : %@", sqlFileName);
        return NO;
    }
    
    // Document ディレクトリを作成する (単体テストだとなぜかできてない)
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *dbdir = [[Database instance] dbPath:@""];
    if (![fm fileExistsAtPath:dbdir]) {
        [fm createDirectoryAtPath:dbdir withIntermediateDirectories:NO
                       attributes:nil error:NULL];
    }

    NSString *dbPath = [[Database instance] dbPath:@"CashFlow.db"];
    //NSLog(@"install db: %@", dbPath);
    
    // load sql
    NSData *data = [NSData dataWithContentsOfFile:sqlPath];
    char *sql = malloc([data length] + 1);
    [data getBytes:sql];
    sql[[data length]] = '\0'; // null terminate

    sqlite3 *handle;
    if (sqlite3_open([dbPath UTF8String], &handle) != 0) {
        NSLog(@"sqlite3_open failed!");
        // ### ASSERT?
        return NO;
    }
    
    if (sqlite3_exec(handle, sql, NULL, NULL, NULL) != SQLITE_OK) {
        NSLog(@"sqlite3_exec failed : %s", sqlite3_errmsg(handle));
        return NO;
        // ### ASSERT?
    }
    
    sqlite3_close(handle);

    free(sql);
    
    // load database
    DataModel *dm = [DataModel instance];
    [dm load];
#if 0
    [dm startLoad:nil];
    while (!dm.isLoadDone) {
        [NSThread sleepForTimeInterval:0.05];
    }
#endif
    
    return YES;
}

@end

#if 0
#import "Pin.h"

// dummy
@implementation PinController

@synthesize pin, newPin;

- (void)_allDone;
{
}

- (PinViewController *)_getPinViewController
{
    return nil;
}

- (void)firstPinCheck:(UIViewController *)vc
{
}

- (void)modifyPin:(UIViewController *)currentVc
{
}

- (void)pinViewFinished:(PinViewController *)vc isCancel:(BOOL)isCancel
{
}

@end
#endif

