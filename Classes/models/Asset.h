// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import "Transaction.h"
#import "Database.h"
#import "AssetBase.h"
#import "AssetEntry.h"

// asset types
#define NUM_ASSET_TYPES 5

#define ASSET_CASH  0
#define ASSET_BANK  1
#define	ASSET_CARD  2
#define ASSET_INVEST 3
#define ASSET_EMONEY 4


#define MAX_TRANSACTIONS	50000

@class Database;

//
// 資産 (総勘定元帳の勘定に相当)
// 
@interface Asset : AssetBase

+ (int)numAssetTypes;
+ (NSArray*)typeNamesArray;
+ (NSString*)typeNameWithType:(int)type;
+ (NSString*)iconNameWithType:(int)type;

- (void)rebuild;

- (int)entryCount;
- (AssetEntry *)entryAt:(int)n;
- (void)insertEntry:(AssetEntry *)tr;
- (void)replaceEntryAtIndex:(int)index withObject:(AssetEntry *)t;
- (void)deleteEntryAt:(int)n;
- (void)deleteOldEntriesBefore:(NSDate*)date;
- (int)firstEntryByDate:(NSDate*)date;

- (double)lastBalance;
- (void)updateInitialBalance;

@end
