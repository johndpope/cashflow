// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import "Journal.h"
#import "Ledger.h"
#import "Category.h"
#import "DescLRU.h"
#import "Database.h"

@protocol DataModelDelegate
- (void)dataModelLoaded;
@end

@interface DataModel : NSObject
{
    // Journal
    Journal *mJournal;

    // Ledger
    Ledger *mLedger;

    // Category
    Categories *mCategories;
    
    id<DataModelDelegate> mDelegate;
    BOOL mIsLoadDone;
}

@property(nonatomic,retain) Journal *journal;
@property(nonatomic,retain) Ledger *ledger;
@property(nonatomic,retain) Categories *categories;
@property(readonly) BOOL isLoadDone;

+ (DataModel *)instance;
+ (void)finalize;

+ (void)setDbName:(NSString *)dbname; // for unit testing...

+ (Journal *)journal;
+ (Ledger *)ledger;
+ (Categories *)categories;

+ (NSDateFormatter *)dateFormatter;
+ (NSDateFormatter *)dateFormatter:(BOOL)withDayOfWeek;
+ (NSDateFormatter *)dateFormatter:(NSDateFormatterStyle)timeStyle withDayOfWeek:(BOOL)withDayOfWeek;


// initializer
- (id)init;

// load/save
- (void)startLoad:(id<DataModelDelegate>)delegate;
- (void)loadThread:(id)dummy;
- (void)load;

// utility operation
//+ (NSString*)currencyString:(double)x;

- (int)categoryWithDescription:(NSString *)desc;

@end
