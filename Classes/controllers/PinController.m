// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "PinController.h"
#import "AppDelegate.h"

@implementation PinController
@synthesize pin = mPin, pinNew = mPinNew;

#define INITIAL -1
#define FIRST_PIN_CHECK 0
#define ENTER_CURRENT_PIN 1
#define ENTER_NEW_PIN1 2
#define ENTER_NEW_PIN2 3

static PinController *thePinController = nil;

+ (PinController *)pinController
{
    if (thePinController == nil) {
        thePinController = [PinController new];
        return thePinController;
    }
    return nil;
}

- (id)init
{
    self = [super init];
    if (self) {
        mState = -1;
        self.pinNew = nil;
        mNavigationController = nil;

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.pin = [defaults stringForKey:@"PinCode"];

        if (mPin && mPin.length == 0) {
            self.pin = nil;
        }
    }
    return self;
}

    
- (void)_allDone
{
    [mNavigationController dismissModalViewControllerAnimated:YES];
    thePinController = nil;
}

//
// 起動時の Pin チェックを開始
//
- (void)firstPinCheck:(UIViewController *)currentVc
{
    ASSERT(state == INITIAL);

    if (mPin == nil) {
        // no need to check pin.
        thePinController = nil;
        return;
    }

    // get topmost modal view controller
    while (currentVc.modalViewController != nil) {
        currentVc = currentVc.modalViewController;
    }
    

    // create PinViewController
    PinViewController *vc = [self _getPinViewController];
    vc.title = _L(@"Enter PIN");
    vc.enableCancel = NO;

    mState = FIRST_PIN_CHECK;

    // show PinViewController
    mNavigationController = [[UINavigationController alloc] initWithRootViewController:vc];
    [currentVc presentModalViewController:mNavigationController animated:NO];
}

- (void)modifyPin:(UIViewController *)currentVc
{
    ASSERT(state == INITIAL);

    PinViewController *vc = [self _getPinViewController];
    
    if (mPin != nil) {
        // check current pin
        mState = ENTER_CURRENT_PIN;
        vc.title = _L(@"Enter PIN");
    } else {
        // enter 1st pin
        mState = ENTER_NEW_PIN1;
        vc.title = _L(@"Enter new PIN");
    }
        
    mNavigationController = [[UINavigationController alloc] initWithRootViewController:vc];
    [currentVc presentModalViewController:mNavigationController animated:YES];
}

#pragma mark PinViewDelegate

- (BOOL)pinViewCheckPin:(PinViewController *)vc
{
    return [vc.value isEqualToString:mPin];
}

- (void)pinViewFinished:(PinViewController *)vc isCancel:(BOOL)isCancel
{
    if (isCancel) {
        [self _allDone];
        return;
    }

    BOOL retry = NO;
    BOOL isBadPin = NO;
    PinViewController *newvc = nil;

    switch (mState) {
    case FIRST_PIN_CHECK:
    case ENTER_CURRENT_PIN:
        ASSERT(pin != nil);
        if (![vc.value isEqualToString:mPin]) {
            isBadPin = YES;
            retry = YES;
        }
        else if (mState == ENTER_CURRENT_PIN) {
            mState = ENTER_NEW_PIN1;
            newvc = [self _getPinViewController];        
            newvc.title = _L(@"Enter new PIN");
        }
        break;

    case ENTER_NEW_PIN1:
        self.pinNew = [NSString stringWithString:vc.value]; // TBD
        mState = ENTER_NEW_PIN2;
        newvc = [self _getPinViewController];        
        newvc.title = _L(@"Retype new PIN");
        break;

    case ENTER_NEW_PIN2:
        NSLog(@"%@", mPinNew);
        if ([vc.value isEqualToString:mPinNew]) {
            // set new pin
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:mPinNew forKey:@"PinCode"];
            [defaults synchronize];
        } else {
            isBadPin = YES;
        }
        break;
    }

    // invalid pin
    if (isBadPin) {
        UIAlertView *v = [[UIAlertView alloc]
                             initWithTitle:_L(@"Invalid PIN")
                             message:_L(@"PIN code does not match.")
                             delegate:nil
                             cancelButtonTitle:@"Close"
                             otherButtonTitles:nil];
        [v show];
    }
    if (retry) {
        return;
    }

    // Show new vc if needed, otherwise all done.
    if (newvc) {
        [mNavigationController pushViewController:newvc animated:YES];
    } else {
        [self _allDone];
    }
}

- (PinViewController *)_getPinViewController
{
    PinViewController *vc = [PinViewController new];
    vc.enableCancel = YES;
    vc.delegate = self;
    return vc;
}

@end
