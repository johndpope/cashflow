// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

// AssetEntry

#import "AppDelegate.h"
#import "Asset.h"

@implementation AssetEntry

@synthesize assetKey = mAssetKey;
@synthesize transaction = mTransaction;
@synthesize value = mValue;
@synthesize balance = mBalance;


- (id)init
{
    self = [super init];

    mTransaction = nil;
    mAssetKey = -1;
    mValue = 0.0;
    mBalance = 0.0;

    return self;
}

- (id)initWithTransaction:(Transaction *)t withAsset:(Asset *)asset
{
    self = [self init];

    mAssetKey = asset.pid;
    
    if (t == nil) {
        // 新規エントリ生成
        self.transaction = [[Transaction alloc] init];
        mTransaction.asset = self.assetKey;
    }
    else {
        self.transaction = t;

        if ([self isDstAsset]) {
            mValue = -t.value;
        } else {
            mValue = t.value;
        }
    }

    return self;
}

//
// 資産間移動の移動先取引なら YES を返す
//
- (BOOL)isDstAsset
{
    if (mTransaction.type == TYPE_TRANSFER && mAssetKey == mTransaction.dstAsset) {
        return YES;
    }

    return NO;
}

- (Transaction *)transaction
{
    [self _setupTransaction];
    return mTransaction;
}

// 値を Transaction に書き戻す
- (void)_setupTransaction
{
    if (mTransaction.type == TYPE_ADJ) {
        mTransaction.balance = mBalance;
        mTransaction.hasBalance = YES;
    } else {
        mTransaction.hasBalance = NO;
        if ([self isDstAsset]) {
            mTransaction.value = -mValue;
        } else {
            mTransaction.value = mValue;
        }
    }
}

// TransactionViewController 用の値を返す
- (double)evalue
{
    double ret = 0.0;

    switch (mTransaction.type) {
    case TYPE_INCOME:
        ret = mValue;
        break;
    case TYPE_OUTGO:
        ret = -mValue;
        break;
    case TYPE_ADJ:
        ret = mBalance;
        break;
    case TYPE_TRANSFER:
        if ([self isDstAsset]) {
            ret = mValue;
        } else {
            ret = -mValue;
        }
        break;
    }
	
    if (ret == 0.0) {
        ret = 0.0;	// avoid '-0'
    }
    return ret;
}

// 編集値をセット
- (void)setEvalue:(double)v
{
    switch (mTransaction.type) {
    case TYPE_INCOME:
        mValue = v;
        break;
    case TYPE_OUTGO:
        mValue = -v;
        break;
    case TYPE_ADJ:
        mBalance = v;
        break;
    case TYPE_TRANSFER:
        if ([self isDstAsset]) {
            mValue = v;
        } else {
            mValue = -v;
        }
        break;
    }
}

// 種別変更
//   type のほか、transaction の dst_asset, asset, value も調整する
- (BOOL)changeType:(int)type assetKey:(int)as dstAssetKey:(int)das
{
    if (type == TYPE_TRANSFER) {
        if (das == self.assetKey) {
            // 自分あて転送は許可しない
            // ### TBD
            return NO;
        }

        mTransaction.type = TYPE_TRANSFER;
        [self setDstAsset:das];
    } else {
        // 資産間移動でない取引に変更した場合、強制的に指定資産の取引に変更する
        double ev = self.evalue;
        mTransaction.type = type;
        mTransaction.asset = as;
        mTransaction.dstAsset = -1;
        self.evalue = ev;
    }
    return YES;
}

// 転送先資産のキーを返す
- (int)dstAsset
{
    if (mTransaction.type != TYPE_TRANSFER) {
        ASSERT(NO);
        return -1;
    }

    if ([self isDstAsset]) {
        return mTransaction.asset;
    }

    return mTransaction.dstAsset;
}

- (void)setDstAsset:(int)as
{
    if (mTransaction.type != TYPE_TRANSFER) {
        ASSERT(NO);
        return;
    }

    if ([self isDstAsset]) {
        mTransaction.asset = as;
    } else {
        mTransaction.dstAsset = as;
    }
}

- (id)copyWithZone:(NSZone *)zone
{
    AssetEntry *e = [[AssetEntry alloc] init];
    e.assetKey = self.assetKey;
    e.value = self.value;
    e.balance = self.balance;
    e.transaction = [self.transaction copy];

    return e;
}

@end
