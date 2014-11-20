// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#if 0 // NOT IN USE

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Transaction.h"

@class TransactionViewController;
@class EditValueViewController;

@protocol EditValueViewDelegate
- (void)editValueViewChanged:(EditValueViewController *)vc;
@end

@interface EditValueViewController : UIViewController {
    NSMutableString *numstr;

    IBOutlet UILabel *numLabel;
    IBOutlet UIButton *button_Clear;
    IBOutlet UIButton *button_BS;
    IBOutlet UIButton *button_inv;
    IBOutlet UIButton *button_Period;
    IBOutlet UIButton *button_0;
    IBOutlet UIButton *button_1;
    IBOutlet UIButton *button_2;
    IBOutlet UIButton *button_3;
    IBOutlet UIButton *button_4;
    IBOutlet UIButton *button_5;
    IBOutlet UIButton *button_6;
    IBOutlet UIButton *button_7;
    IBOutlet UIButton *button_8;
    IBOutlet UIButton *button_9;

    id<EditValueViewDelegate> mDelegate;
    double mValue;
}

@property(nonatomic,assign) id<EditValueViewDelegate> delegate;
@property(nonatomic,assign) double value;

- (IBAction)onNumButtonDown:(id)sender;
- (IBAction)onNumButtonPressed:(id)sender;

// private method
- (void)doneAction;
- (void)updateLabel;

@end
#endif
