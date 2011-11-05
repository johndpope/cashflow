// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import "DataModel.h"
#import "GenEditTextVC.h"

@class CategoryListViewController;

@protocol CategoryListViewDelegate
- (void)categoryListViewChanged:(CategoryListViewController *)vc;
@end

@interface CategoryListViewController : UITableViewController
    <GenEditTextViewDelegate>
{
    BOOL mIsSelectMode;
    int mSelectedIndex;
	
    id<CategoryListViewDelegate> __unsafe_unretained mDelegate;
}

@property(nonatomic,assign) BOOL isSelectMode;
@property(nonatomic,assign) int selectedIndex;
@property(nonatomic,assign) id<CategoryListViewDelegate> delegate;

@end
