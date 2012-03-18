// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import "Transaction.h"

//
// 各資産（勘定）のエントリ
//
@interface AssetEntry : NSObject {
    @private
    int mAssetKey;
    double mValue;
    double mBalance;

    Transaction *mTransaction;
}

@property(nonatomic,assign) int assetKey;
@property(nonatomic,retain) Transaction *transaction;
@property(nonatomic,assign) double value;
@property(nonatomic,assign) double balance;
@property(nonatomic,assign) double evalue;

- (id)initWithTransaction:(Transaction *)t withAsset:(Asset *)asset;
- (BOOL)changeType:(int)type assetKey:(int)as dstAssetKey:(int)das;
- (int)dstAsset;
- (void)setDstAsset:(int)as;
- (BOOL)isDstAsset;

@end
