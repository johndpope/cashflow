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

- (id)init
{
    self = [super init];

    _transaction = nil;
    _assetKey = -1;
    _value = 0.0;
    _balance = 0.0;

    return self;
}

- (id)initWithTransaction:(Transaction *)t withAsset:(Asset *)asset
{
    self = [self init];

    _assetKey = asset.pid;
    
    if (t == nil) {
        // 新規エントリ生成
        _transaction = [Transaction new];
        _transaction.asset = self.assetKey;
    }
    else {
        _transaction = t;

        if ([self isDstAsset]) {
            _value = -t.value;
        } else {
            _value = t.value;
        }
    }

    return self;
}

//
// 資産間移動の移動先取引なら YES を返す
//
- (BOOL)isDstAsset
{
    if (_transaction.type == TYPE_TRANSFER && self.assetKey == _transaction.dstAsset) {
        return YES;
    }

    return NO;
}

// property transaction : read 処理
- (Transaction *)transaction
{
    [self _setupTransaction];
    return _transaction;
}

// 値を Transaction に書き戻す
- (void)_setupTransaction
{
    if (_transaction.type == TYPE_ADJ) {
        _transaction.balance = self.balance;
        _transaction.hasBalance = YES;
    } else {
        _transaction.hasBalance = NO;
        if ([self isDstAsset]) {
            _transaction.value = -self.value;
        } else {
            _transaction.value = self.value;
        }
    }
}

// TransactionViewController 用の値を返す
- (double)evalue
{
    double ret = 0.0;

    switch (_transaction.type) {
    case TYPE_INCOME:
        ret = self.value;
        break;
    case TYPE_OUTGO:
        ret = -self.value;
        break;
    case TYPE_ADJ:
        ret = self.balance;
        break;
    case TYPE_TRANSFER:
        if ([self isDstAsset]) {
            ret = self.value;
        } else {
            ret = -self.value;
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
    switch (_transaction.type) {
    case TYPE_INCOME:
        self.value = v;
        break;
    case TYPE_OUTGO:
        self.value = -v;
        break;
    case TYPE_ADJ:
        self.balance = v;
        break;
    case TYPE_TRANSFER:
        if ([self isDstAsset]) {
            self.value = v;
        } else {
            self.value = -v;
        }
        break;
    }
}

// 種別変更
//   type のほか、transaction の dst_asset, asset, value も調整する
- (BOOL)changeType:(NSInteger)type assetKey:(NSInteger)as dstAssetKey:(NSInteger)das
{
    if (type == TYPE_TRANSFER) {
        if (das == self.assetKey) {
            // 自分あて転送は許可しない
            // ### TBD
            return NO;
        }

        _transaction.type = TYPE_TRANSFER;
        [self setDstAsset:das];
    } else {
        // 資産間移動でない取引に変更した場合、強制的に指定資産の取引に変更する
        double ev = self.evalue;
        _transaction.type = type;
        _transaction.asset = as;
        _transaction.dstAsset = -1;
        self.evalue = ev;
    }
    return YES;
}

// 転送先資産のキーを返す
- (NSInteger)dstAsset
{
    if (_transaction.type != TYPE_TRANSFER) {
        ASSERT(NO);
        return -1;
    }

    if ([self isDstAsset]) {
        return _transaction.asset;
    }

    return _transaction.dstAsset;
}

- (void)setDstAsset:(NSInteger)as
{
    if (_transaction.type != TYPE_TRANSFER) {
        ASSERT(NO);
        return;
    }

    if ([self isDstAsset]) {
        _transaction.asset = as;
    } else {
        _transaction.dstAsset = as;
    }
}

- (id)copyWithZone:(NSZone *)zone
{
    AssetEntry *e = [AssetEntry new];
    e.assetKey = self.assetKey;
    e.value = self.value;
    e.balance = self.balance;
    e.transaction = [_transaction copy];

    return e;
}

@end
