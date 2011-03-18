// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "Report.h"
#import "AppDelegate.h"

@implementation CatReport

@synthesize category = mCategory;
@synthesize assetKey = mAssetKey;
@synthesize sum = mSum;
@synthesize transactions = mTransactions;

- (id)initWithCategory:(int)category withAsset:(int)assetKey
{
    self = [super init];
    if (self != nil) {
        mCategory = category;
        mAssetKey = assetKey;
        mTransactions = [[NSMutableArray alloc] init];
        mSum = 0.0;
    }
    return self;
}

- (void)dealloc
{
    [mTransactions release];
    [super dealloc];
}

- (void)addTransaction:(Transaction*)t
{
    if (mAssetKey >= 0 && t.dstAsset == mAssetKey) {
        mSum += -t.value; // 資産間移動の移動先
    } else {
        mSum += t.value;
    }

    [mTransactions addObject:t];
}

- (NSString *)title
{
    if (mCategory < 0) {
        return _L(@"No category");
    }
    return [[DataModel categories] categoryStringWithKey:mCategory];
}

@end
