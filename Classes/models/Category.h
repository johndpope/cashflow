// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import "Database.h"
#import "TCategoryBase.h"

@interface TCategory : TCategoryBase
@end

@interface Categories : NSObject

- (void)reload;
- (NSInteger)count;
- (TCategory*)categoryAtIndex:(NSInteger)n;
- (NSInteger)categoryIndexWithKey:(NSInteger)key;
- (NSString*)categoryStringWithKey:(NSInteger)key;

-(TCategory*)addCategory:(NSString *)name;
-(void)updateCategory:(TCategory*)category;
-(void)deleteCategoryAtIndex:(NSInteger)index;
-(void)reorderCategory:(NSInteger)from to:(NSInteger)to;
-(void)renumber;

@end
