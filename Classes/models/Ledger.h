// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

// 総勘定元帳

#import <UIKit/UIKit.h>
#import "Journal.h"
#import "Asset.h"
#import "Category.h"
#import "Database.h"

@interface Ledger : NSObject
{
    @private

    // Assets
    NSMutableArray *mAssets;
}

@property(nonatomic) NSMutableArray *assets;

// asset operation
- (void)load;
- (void)rebuild;
- (int)assetCount;
- (Asset *)assetAtIndex:(int)n;
- (Asset*)assetWithKey:(int)key;
- (int)assetIndexWithKey:(int)key;

- (void)addAsset:(Asset *)as;
- (void)deleteAsset:(Asset *)as;
- (void)updateAsset:(Asset*)asset;
- (void)reorderAsset:(int)from to:(int)to;

@end
