// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <AudioToolbox/AudioToolbox.h>

#import "PinVC.h"
#import "AppDelegate.h"

@interface PinViewController()
- (void)_onKeyIn:(NSString *)ch;
- (void)doneAction:(id)sender;
- (void)cancelAction:(id)sender;
@end

@implementation PinViewController
@synthesize value = mValue, enableCancel = mEnableCancel, delegate = mDelegate;

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
    mValue = [NSMutableString new];
    
    mValueLabel.text = @"";

    //self.title = _L(@"PIN");
    self.navigationItem.rightBarButtonItem = 
        [[UIBarButtonItem alloc]
             initWithBarButtonSystemItem:UIBarButtonSystemItemDone
             target:self
             action:@selector(doneAction:)];

    self.navigationItem.leftBarButtonItem = nil;
    if (mEnableCancel) {
        self.navigationItem.leftBarButtonItem = 
            [[UIBarButtonItem alloc]
                 initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                 target:self
                 action:@selector(cancelAction:)];
    }
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
        [mValue setString:@""];
    }
    else if (sender == button_BS) {
        // バックスペース
        int len = mValue.length;
        if (len > 0) {
            [mValue deleteCharactersInRange:NSMakeRange(len-1, 1)];
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
    
    [self _onKeyIn:ch];
}

- (void)_onKeyIn:(NSString *)ch
{
    if (ch != nil) {
        [mValue appendString:ch];
    }
	
    int len = mValue.length;
    NSMutableString *p = [[NSMutableString alloc] initWithCapacity:len];
    for (int i = 0; i < len; i++) {
        [p appendString:@"●"];
    }
    mValueLabel.text = p;

    if ([mDelegate pinViewCheckPin:self]) {
        [self doneAction:nil];
    }
}

- (void)doneAction:(id)sender
{
    [mDelegate pinViewFinished:self isCancel:NO];

    [mValue setString:@""];
    mValueLabel.text = @"";
}

- (void)cancelAction:(id)sender
{
    [mDelegate pinViewFinished:self isCancel:YES];

    [mValue setString:@""];
    mValueLabel.text = @"";
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (IS_IPAD) return YES;
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
