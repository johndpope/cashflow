// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

//
// Journal : 仕訳帳
//

#import <UIKit/UIKit.h>
#import "Transaction.h"

//
// 仕訳帳
// 
@interface Journal : NSObject <NSFastEnumeration> {
    @private
    NSMutableArray *mEntries;
}

@property(nonatomic,readonly) NSMutableArray *entries;

- (void)reload;

- (void)insertTransaction:(Transaction*)tr;
- (void)replaceTransaction:(Transaction *)from withObject:(Transaction*)to;
- (BOOL)deleteTransaction:(Transaction *)tr withAsset:(Asset *)asset;
- (void)deleteAllTransactionsWithAsset:(Asset *)asset;

@end
