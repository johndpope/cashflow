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

@implementation DataModel

@synthesize journal = mJournal;
@synthesize ledger = mLedger;
@synthesize categories = mCategories;
@synthesize isLoadDone = mIsLoadDone;

static DataModel *theDataModel = nil;

+ (DataModel *)instance
{
    if (!theDataModel) {
        theDataModel = [[DataModel alloc] init];
        //[theDataModel load];
    }
    return theDataModel;
}

+ (void)finalize
{
    if (theDataModel) {
        [theDataModel release];
        theDataModel = nil;
    }
}

- (id)init
{
    [super init];

    mJournal = [[Journal alloc] init];
    mLedger = [[Ledger alloc] init];
    mCategories = [[Categories alloc] init];
    mIsLoadDone = NO;
	
    return self;
}

- (void)dealloc 
{
    [mJournal release];
    [mLedger release];
    [mCategories release];

    [super dealloc];
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
    [thread release];
}

- (void)loadThread:(id)dummy
{
    NSAutoreleasePool *pool;
    pool = [[NSAutoreleasePool alloc] init];

    [self load];
    
    mIsLoadDone = YES;
    if (mDelegate) {
        [mDelegate dataModelLoaded];
    }
    
    [pool release];
    [NSThread exit];
}

- (void)load
{
    Database *db = [Database instance];

    // Load from DB
    if (![db open:DBNAME]) {
    }

    [Transaction migrate];
    [Asset migrate];
    [Category migrate];
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
            [dfDateOnly retain];
        }
        return dfDateOnly;
    } else {
        if (dfDateTime == nil) {
            dfDateTime = [self dateFormatter:NSDateFormatterShortStyle withDayOfWeek:YES];
            [dfDateTime retain];
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
    NSDateFormatter *df = [[[NSDateFormatter alloc] init] autorelease];
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

@end
