// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "GenSelectListVC.h"

@class EditTypeViewController;

@protocol EditTypeViewDelegate
- (void)editTypeViewChanged:(EditTypeViewController*)vc;
@end

@interface EditTypeViewController : UITableViewController <GenSelectListViewDelegate>
{
    id<EditTypeViewDelegate> __unsafe_unretained mDelegate;

    int mType;
    int mDstAsset;
}

@property(nonatomic,assign) id<EditTypeViewDelegate> delegate;
@property(nonatomic,assign) int type;
@property(nonatomic,assign) int dstAsset;

@end
