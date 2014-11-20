// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "PinController.h"
#import "AppDelegate.h"

@implementation PinController
{
    int _state;
    UINavigationController *_navigationController;
}

#define INITIAL -1
#define FIRST_PIN_CHECK 0
#define ENTER_CURRENT_PIN 1
#define ENTER_NEW_PIN1 2
#define ENTER_NEW_PIN2 3

static PinController *thePinController = nil;

+ (PinController *)sharedController
{
    if (thePinController == nil) {
        thePinController = [PinController new];
    }
    return thePinController;
}

+ (void)_deleteSingleton
{
    thePinController = nil;
}

- (id)init
{
    self = [super init];
    if (self) {
        _state = INITIAL;
        self.pinNew = nil;
        _navigationController = nil;

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.pin = [defaults stringForKey:@"PinCode"];

        if (_pin && _pin.length == 0) {
            self.pin = nil;
        }
    }
    return self;
}

- (BOOL)hasPin
{
    return self.pin != nil;
}

- (void)deletePin
{
    self.pin = nil;
    [self _savePin:nil];
}

- (void)_savePin:(NSString *)pin
{
    self.pin = pin;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:pin forKey:@"PinCode"];
    [defaults synchronize];
}

- (void)_allDone:(PinViewController *)pinViewController;
{
    if (pinViewController != nil) {
        pinViewController.delegate = nil;
    }
    [_navigationController dismissViewControllerAnimated:YES completion:NULL];
    thePinController = nil; // delete myself
}

//
// 起動時の Pin チェックを開始
//
- (void)firstPinCheck:(UIViewController *)currentVc
{
    // 二重起動防止
    // Pin チェックや PIN 変更中にサスペンドに入る場合
    if (_state != INITIAL) {
        return;
    }

    if (_pin == nil) {
        // no need to check pin.
        thePinController = nil;
        return;
    }

    // get topmost modal view controller
    while (currentVc.presentedViewController != nil) {
        currentVc = currentVc.presentedViewController;
    }
    

    // create PinViewController
    PinViewController *vc = [self _getPinViewController];
    vc.title = _L(@"Enter passcode");
    vc.enableCancel = NO;

    _state = FIRST_PIN_CHECK;

    // show PinViewController
    _navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
    [currentVc presentViewController:_navigationController animated:NO completion:NULL];
    
    [vc tryTouchId];
}

- (void)modifyPin:(UIViewController *)currentVc
{
    ASSERT(state == INITIAL);

    PinViewController *vc = [self _getPinViewController];
    
    if (_pin != nil) {
        // check current pin
        _state = ENTER_CURRENT_PIN;
        vc.title = _L(@"Enter passcode");
    } else {
        // enter 1st pin
        _state = ENTER_NEW_PIN1;
        vc.title = _L(@"Enter new passcode");
    }
        
    _navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
    [currentVc presentViewController:_navigationController animated:YES completion:NULL];
}

#pragma mark PinViewDelegate

- (BOOL)pinViewCheckPin:(PinViewController *)vc
{
    return [vc.value isEqualToString:_pin];
}

- (void)pinViewFinished:(PinViewController *)vc isCancel:(BOOL)isCancel
{
    if (isCancel) {
        [self _allDone:vc];
        return;
    }

    BOOL retry = NO;
    BOOL isBadPin = NO;
    PinViewController *newvc = nil;

    switch (_state) {
    case FIRST_PIN_CHECK:
    case ENTER_CURRENT_PIN:
        ASSERT(pin != nil);
        if (![vc.value isEqualToString:_pin]) {
            isBadPin = YES;
            retry = YES;
        }
        else if (_state == ENTER_CURRENT_PIN) {
            _state = ENTER_NEW_PIN1;
            newvc = [self _getPinViewController];        
            newvc.title = _L(@"Enter new passcode");
        }
        break;

    case ENTER_NEW_PIN1:
        self.pinNew = [NSString stringWithString:vc.value]; // TBD
        _state = ENTER_NEW_PIN2;
        newvc = [self _getPinViewController];        
        newvc.title = _L(@"Retype new passcode");
        break;

    case ENTER_NEW_PIN2:
        NSLog(@"%@", _pinNew);
        if ([vc.value isEqualToString:_pinNew]) {
            // set new pin
            [self _savePin:_pinNew];
        } else {
            isBadPin = YES;
        }
        break;
    }

    // invalid pin
    if (isBadPin) {
        UIAlertView *v = [[UIAlertView alloc]
                             initWithTitle:_L(@"Invalid passcode")
                             message:_L(@"Passcode does not match.")
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
        [_navigationController pushViewController:newvc animated:YES];
    } else {
        [self _allDone:vc];
    }
}

/**
 * TouchID 認証完了
 */
- (void)pinViewTouchIdFinished:(PinViewController *)vc {
    if (_state == FIRST_PIN_CHECK) {
        [self _allDone:vc];
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
