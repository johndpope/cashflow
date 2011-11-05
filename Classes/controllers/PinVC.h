// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */
// PIN code view

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class PinViewController;

@protocol PinViewDelegate
- (void)pinViewFinished:(PinViewController *)vc isCancel:(BOOL)isCancel;
- (BOOL)pinViewCheckPin:(PinViewController *)vc;
@end

@interface PinViewController : UIViewController 
{
    IBOutlet UILabel *mValueLabel;

    IBOutlet UIButton *button_Clear;
    IBOutlet UIButton *button_BS;
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

    NSMutableString *mValue;
    BOOL mEnableCancel;
    id<PinViewDelegate> __unsafe_unretained mDelegate;
}

@property(nonatomic,assign) id<PinViewDelegate> delegate;
@property(nonatomic,retain) NSMutableString *value;
@property(nonatomic,assign) BOOL enableCancel;

- (IBAction)onNumButtonDown:(id)sender;
- (IBAction)onNumButtonPressed:(id)sender;
- (void)_onKeyIn:(NSString *)ch;
- (void)doneAction:(id)sender;
- (void)cancelAction:(id)sender;

@end
