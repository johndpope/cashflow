// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Transaction.h"

#import "CalendarViewController.h"

@class TransactionViewController;
@class EditDateViewController;

@protocol EditDateViewDelegate
- (void)editDateViewChanged:(EditDateViewController*)vc;
@end

@interface EditDateViewController : UIViewController <CalendarViewControllerDelegate> 

@property(nonatomic,unsafe_unretained) id<EditDateViewDelegate> delegate;
@property(nonatomic,strong) NSDate *date;

@end
