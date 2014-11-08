// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <AudioToolbox/AudioToolbox.h>
#import <LocalAuthentication/LocalAuthentication.h>

#import "PinVC.h"
#import "AppDelegate.h"
#import "Config.h"

@interface PinViewController ()
{
    IBOutlet UILabel *_valueLabel;
    
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
    
    NSMutableString *_value;
    BOOL _enableCancel;
    id<PinViewDelegate> __unsafe_unretained _delegate;
}
@end

@implementation PinViewController

- (id)init
{
    if (IS_IPAD) {
        self = [super initWithNibName:@"PinView-ipad" bundle:nil];
    } else {
        self = [super initWithNibName:@"PinView" bundle:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // iOS7 hack
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) self.edgesForExtendedLayout = UIRectEdgeNone;
    
    _value = [NSMutableString new];
    
    _valueLabel.text = @"";

    //self.title = _L(@"PIN");
    self.navigationItem.rightBarButtonItem = 
        [[UIBarButtonItem alloc]
             initWithBarButtonSystemItem:UIBarButtonSystemItemDone
             target:self
             action:@selector(doneAction:)];

    self.navigationItem.leftBarButtonItem = nil;
    if (_enableCancel) {
        self.navigationItem.leftBarButtonItem = 
            [[UIBarButtonItem alloc]
                 initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                 target:self
                 action:@selector(cancelAction:)];
    }

    // Notifiction 受け取り手続き : アプリが foreground に回ったときに通知を受ける
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(willEnterForeground) name:@"willEnterForeground" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}


- (IBAction)onNumButtonDown:(id)sender
{
    // play keyboard click sound
    AudioServicesPlaySystemSound(1105);
}

- (IBAction)onNumButtonPressed:(id)sender
{
    NSString *ch = nil;

    if (sender == button_Clear) {
        [_value setString:@""];
    }
    else if (sender == button_BS) {
        // バックスペース
        NSInteger len = _value.length;
        if (len > 0) {
            [_value deleteCharactersInRange:NSMakeRange(len-1, 1)];
        }
    }
		
    else if (sender == button_0) ch = @"0";
    else if (sender == button_1) ch = @"1";
    else if (sender == button_2) ch = @"2";
    else if (sender == button_3) ch = @"3";
    else if (sender == button_4) ch = @"4";
    else if (sender == button_5) ch = @"5";
    else if (sender == button_6) ch = @"6";
    else if (sender == button_7) ch = @"7";
    else if (sender == button_8) ch = @"8";
    else if (sender == button_9) ch = @"9";
    
    [self onKeyIn:ch];
}

- (void)onKeyIn:(NSString *)ch
{
    if (ch != nil) {
        [_value appendString:ch];
    }
	
    NSInteger len = _value.length;
    NSMutableString *p = [[NSMutableString alloc] initWithCapacity:len];
    for (int i = 0; i < len; i++) {
        [p appendString:@"●"];
    }
    _valueLabel.text = p;

    if ([_delegate pinViewCheckPin:self]) {
        [self doneAction:nil];
    }
}

- (void)doneAction:(id)sender
{
    [_delegate pinViewFinished:self isCancel:NO];

    [_value setString:@""];
    _valueLabel.text = @"";
}

- (void)cancelAction:(id)sender
{
    [_delegate pinViewFinished:self isCancel:YES];

    [_value setString:@""];
    _valueLabel.text = @"";
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return IS_IPAD ? YES : interfaceOrientation == UIInterfaceOrientationPortrait;
}


/**
 * アプリが foreground になった時の処理。
 * TouchID 関連処理。
 * これは AppDelegate の applicationWillEnterForeground から呼び出される。
 */
- (void)willEnterForeground
{
    NSLog(@"PinViewController : willEnterForeground");

    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1) {
        return; // iOS7以下はTouchID未対応
    }

    if (![Config instance].useTouchId) {
        return; // TouchID 使用しない
    }

    // Touch ID
    LAContext *context = [LAContext new];
    NSError *error = nil;
    
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        [context
         evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
         localizedReason:@"Unlock"
         reply:^(BOOL success, NSError *error){
             if (success) {
                 [_delegate pinViewTouchIdFinished:self];
             }
         }];
    }
}

@end
