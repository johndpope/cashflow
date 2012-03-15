// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

// PIN code controller

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "PinVC.h"

@interface PinController : NSObject <PinViewDelegate>
{
    int mState;
    NSString *mPin;
    NSString *mPinNew;
    UINavigationController *mNavigationController;
}

@property(strong) NSString *pin;
@property(strong) NSString *pinNew;

+ (PinController *)pinController;

- (void)firstPinCheck:(UIViewController *)currentVc;
- (void)modifyPin:(UIViewController *)currentVc;

@end
