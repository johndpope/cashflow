// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Transaction.h"

@class TransactionViewController;
@class EditDescViewController;

@protocol EditDescViewDelegate
- (void)editDescViewChanged:(EditDescViewController*)vc;
@end

@interface EditDescViewController : UIViewController
  <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
{
    IBOutlet UITableView *mTableView;

    UITextField *mTextField;
    NSMutableArray *mDescArray;

    id<EditDescViewDelegate> __unsafe_unretained mDelegate;
    NSString *mDescription;
    int mCategory;
}

@property(nonatomic,assign) id<EditDescViewDelegate> delegate;
@property(nonatomic,retain) NSString *description;
@property(nonatomic,assign) int category;

@property(nonatomic,readonly) UITableView *tableView; // for test

- (void)doneAction;

@end
