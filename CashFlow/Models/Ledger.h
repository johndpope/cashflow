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

@property(nonatomic,strong) NSMutableArray *assets;

// asset operation
- (void)load;
- (void)rebuild;
- (NSInteger)assetCount;
- (Asset *)assetAtIndex:(NSInteger)n;
- (Asset*)assetWithKey:(NSInteger)key;
- (NSInteger)assetIndexWithKey:(NSInteger)key;

- (void)addAsset:(Asset *)as;
- (void)deleteAsset:(Asset *)as;
- (void)updateAsset:(Asset*)asset;
- (void)reorderAsset:(NSInteger)from to:(NSInteger)to;

@end
