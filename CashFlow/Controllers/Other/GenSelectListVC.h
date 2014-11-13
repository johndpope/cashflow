// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class GenSelectListViewController;

@protocol GenSelectListViewDelegate
- (BOOL)genSelectListViewChanged:(GenSelectListViewController*)vc identifier:(NSInteger)id;
@end

@interface GenSelectListViewController : UITableViewController

@property(nonatomic,unsafe_unretained) id<GenSelectListViewDelegate> delegate;
@property(nonatomic,assign) NSInteger identifier;
@property(nonatomic,strong) NSArray *items;
@property(nonatomic,assign) NSInteger selectedIndex;

+ (GenSelectListViewController *)genSelectListViewController:(id<GenSelectListViewDelegate>)delegate items:(NSArray*)ary title:(NSString*)title identifier:(NSInteger)id;

@end
