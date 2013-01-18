// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

// DataModel V2
// (SQLite ver)

#import "AppDelegate.h"
#import "DataModel.h"
#import "CashflowDatabase.h"
#import "Config.h"
#import "DescLRUManager.h"

@interface DataModel()
- (NSDate *)_lastModificationDateOfDatabase;
@end

@implementation DataModel
{
    id<DataModelDelegate> mDelegate;
}

@synthesize journal = mJournal;
@synthesize ledger = mLedger;
@synthesize categories = mCategories;
@synthesize isLoadDone = mIsLoadDone;

static DataModel *theDataModel = nil;

static NSString *theDbName = DBNAME;

+ (DataModel *)instance
{
    if (!theDataModel) {
        theDataModel = [DataModel new];
    }
    return theDataModel;
}

+ (void)finalize
{
    if (theDataModel) {
        theDataModel = nil;
    }
}

// for unit testing
+ (void)setDbName:(NSString *)dbname
{
    theDbName = dbname;
}

- (id)init
{
    self = [super init];

    mJournal = [Journal new];
    mLedger = [Ledger new];
    mCategories = [Categories new];
    mIsLoadDone = NO;
	
    return self;
}


+ (Journal *)journal
{
    return [DataModel instance].journal;
}

+ (Ledger *)ledger
{
    return [DataModel instance].ledger;
}

+ (Categories *)categories
{
    return [DataModel instance].categories;
}

- (void)startLoad:(id<DataModelDelegate>)delegate
{
    mDelegate = delegate;
    mIsLoadDone = NO;
    
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(loadThread:) object:nil];
    [thread start];
}

- (void)loadThread:(id)dummy
{
    @autoreleasepool {

        [self load];
        
        mIsLoadDone = YES;
        if (mDelegate) {
            [mDelegate dataModelLoaded];
        }
    
    }
    [NSThread exit];
}

- (void)load
{
    Database *db = [Database instance];

    // Load from DB
    if (![db open:theDbName]) {
    }

    [Transaction migrate];
    [Asset migrate];
    [TCategory migrate];
    [DescLRU migrate];
    
    [DescLRUManager migrate];
	
    // Load all transactions
    [mJournal reload];

    // Load ledger
    [mLedger load];
    [mLedger rebuild];

    // Load categories
    [mCategories reload];
}

////////////////////////////////////////////////////////////////////////////
// Utility

//
// DateFormatter
//

+ (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *dfDateOnly = nil;
    static NSDateFormatter *dfDateTime = nil;
    
    if ([Config instance].dateTimeMode == DateTimeModeDateOnly) {
        if (dfDateOnly == nil) {
            dfDateOnly = [self dateFormatter:NSDateFormatterNoStyle withDayOfWeek:YES];
        }
        return dfDateOnly;
    } else {
        if (dfDateTime == nil) {
            dfDateTime = [self dateFormatter:NSDateFormatterShortStyle withDayOfWeek:YES];
        }
        return dfDateTime;
    }    
}

+ (NSDateFormatter *)dateFormatter:(BOOL)withDayOfWeek
{
    if ([Config instance].dateTimeMode == DateTimeModeDateOnly) {
        return [self dateFormatter:NSDateFormatterNoStyle withDayOfWeek:withDayOfWeek];
    } else {
        return [self dateFormatter:NSDateFormatterShortStyle withDayOfWeek:withDayOfWeek];
    }
}

+ (NSDateFormatter *)dateFormatter:(NSDateFormatterStyle)timeStyle withDayOfWeek:(BOOL)withDayOfWeek
{
    NSDateFormatter *df = [NSDateFormatter new];
    [df setDateStyle:NSDateFormatterMediumStyle];
    [df setTimeStyle:timeStyle];
    
    NSMutableString *s = [NSMutableString stringWithCapacity:30];
    [s setString:[df dateFormat]];

    if (withDayOfWeek) {
        [s replaceOccurrencesOfString:@"MMM d, y" withString:@"EEE, MMM d, y" options:NSLiteralSearch range:NSMakeRange(0, [s length])];
        [s replaceOccurrencesOfString:@"yyyy/MM/dd" withString:@"yyyy/MM/dd(EEEEE)" options:NSLiteralSearch range:NSMakeRange(0, [s length])];
    }

    [df setDateFormat:s];
    return df;
}


// 摘要からカテゴリを推定する
//
// note: 本メソッドは Asset ではなく DataModel についているべき
//
- (int)categoryWithDescription:(NSString *)desc
{
    Transaction *t = [Transaction find_by_description:desc cond:@"ORDER BY date DESC"];

    if (t == nil) {
        return -1;
    }
    return t.category;
}

#define BACKUP_FILE_VERSION 3
#define BACKUP_FILE_IDENT_PRE @"-- CashFlow Backup Format rev. "
#define BACKUP_FILE_IDENT_POST @" --"

- (NSString *)backupFileIdent
{
    return [NSString stringWithFormat:@"%@%d%@", BACKUP_FILE_IDENT_PRE, BACKUP_FILE_VERSION, BACKUP_FILE_IDENT_POST];
}

/**
 * Ident からバージョン番号を取り出す
 */
- (int)getBackupFileIdentVersion:(NSString *)line
{
    NSString *pattern = [NSString stringWithFormat:@"%@(\\d+)%@", 
                                  BACKUP_FILE_IDENT_PRE, BACKUP_FILE_IDENT_POST];

    NSError *error;
    NSRegularExpression *regex;
    regex = [NSRegularExpression
                regularExpressionWithPattern:pattern
                                     options:0
                                       error:&error];

    NSTextCheckingResult *match;
    match  = [regex firstMatchInString:line
                               options:0
                                 range:NSMakeRange(0, line.length)];
    if (match == nil) return -1;
    
    NSString *verString = [line substringWithRange:[match rangeAtIndex:1]];
    int ver = [verString intValue];
    
    return ver;
}

- (NSString *)getBackupSqlPath
{
    return [[Database instance] dbPath:@"CashFlowBackup.sql"];
}

/**
 * SQL でファイルに書きだす
 */
- (BOOL)backupDatabaseToSql:(NSString *)path
{
    NSMutableString *sql = [NSMutableString new];
    
    [sql appendString:[self backupFileIdent]];
    [sql appendString:@"\n"];

    [Asset getTableSql:sql];
    [Transaction getTableSql:sql];
    [TCategory getTableSql:sql];
    [DescLRU getTableSql:sql];

    return [sql writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:NULL];
}

/**
 * ファイルから SQL を読みだして実行する
 */
- (BOOL)restoreDatabaseFromSql:(NSString *)path
{
    Database *db = [Database instance];

    // 先に VACUUM を実行しておく
    [db exec:@"VACUUM;"];

    // SQL をファイルから読み込む
    NSString *sql = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    if (sql == nil) {
        return NO;
    }

    // check ident
    int ver = [self getBackupFileIdentVersion:sql];
    if (ver < 0) {
        NSLog(@"Invalid backup data ident");
        return NO;
    }
    if (ver > BACKUP_FILE_VERSION) {
        NSLog(@"Backup file version too new");
        return NO;
    }

    // SQL 実行
    [db beginTransaction];
    if (![db exec:sql]) {
        [db rollbackTransaction];
        return NO;
    }
    [db commitTransaction];

    // 再度 VACUUM を実行
    [db exec:@"VACUUM;"];

    return YES;
}

#pragma mark Sync operations

#define KEY_LAST_SYNC_REMOTE_REV        @"LastSyncRemoteRev"
#define KEY_LAST_MODIFIED_DATE_OF_DB    @"LastModifiedDateOfDatabase"

- (void)setLastSyncRemoteRev:(NSString *)rev
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:rev forKey:KEY_LAST_SYNC_REMOTE_REV];
    
    NSLog(@"set last sync remote rev: %@", rev);
}

- (BOOL)isRemoteModifiedAfterSync:(NSString *)currev
{
    if (currev == nil) {
        // リモートが存在しない場合は、変更されていないとみなす。
        return NO;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *lastrev = [defaults objectForKey:KEY_LAST_SYNC_REMOTE_REV];
    if (lastrev == nil) {
        // まだ同期したことがない。remote は変更されているものとみなす
        return YES;
    }
    return ![lastrev isEqualToString:currev];
}

- (NSDate *)_lastModificationDateOfDatabase
{
    Database *db = [Database instance];
    NSString *dbpath = [db dbPath:theDbName];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSDictionary *attrs = [manager attributesOfItemAtPath:dbpath error:nil];
    NSDate *date = attrs[NSFileModificationDate];
    return date;
}

- (void)setSyncFinished
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDate *lastdate = [self _lastModificationDateOfDatabase];
    [defaults setObject:lastdate forKey:KEY_LAST_MODIFIED_DATE_OF_DB];
    
    NSLog(@"sync finished: DB modification date is %@", lastdate);
}

- (BOOL)isModifiedAfterSync
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDate *lastdate = [defaults objectForKey:KEY_LAST_MODIFIED_DATE_OF_DB];
    if (lastdate == nil) {
        // まだ同期したことがない。local は変更されているものとみなす。
        return YES;
    }
    NSDate *curdate = [self _lastModificationDateOfDatabase];
    return ![curdate isEqualToDate:lastdate];
}

@end
