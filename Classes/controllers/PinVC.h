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
- (void)pinViewTouchIdFinished:(PinViewController *)vc;
@end

@interface PinViewController : UIViewController 

@property(nonatomic,unsafe_unretained) id<PinViewDelegate> delegate;
@property(nonatomic,strong) NSMutableString *value;
@property(nonatomic,assign) BOOL enableCancel;

// private, but called from test.
- (void)doneAction:(id)sender;
- (void)cancelAction:(id)sender;
- (void)onKeyIn:(NSString *)ch;

@end
