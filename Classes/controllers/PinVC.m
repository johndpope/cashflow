// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <AudioToolbox/AudioToolbox.h>

#import "PinVC.h"
#import "AppDelegate.h"

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
    mValue = [[NSMutableString alloc] init];

    //self.title = _L(@"PIN");
    self.navigationItem.rightBarButtonItem = 
        [[[UIBarButtonItem alloc]
             initWithBarButtonSystemItem:UIBarButtonSystemItemDone
             target:self
             action:@selector(doneAction:)] autorelease];

    self.navigationItem.leftBarButtonItem = nil;
    if (mEnableCancel) {
        self.navigationItem.leftBarButtonItem = 
            [[[UIBarButtonItem alloc]
                 initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                 target:self
                 action:@selector(cancelAction:)] autorelease];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)dealloc
{
    [mValue release];
    [super dealloc];
}

- (IBAction)onNumButtonDown:(id)sender
{
    // play keyboard click sound
    AudioServicesPlaySystemSound(1105);
}

- (IBAction)onNumButtonPressed:(id)sender
{
    NSString *ch = nil;
    int len;

    if (sender == button_Clear) {
        [mValue setString:@""];
    }
    else if (sender == button_BS) {
        // バックスペース
        len = mValue.length;
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

    if (ch != nil) {
        [mValue appendString:ch];
    }
	
    len = mValue.length;
    NSMutableString *p = [[NSMutableString alloc] initWithCapacity:len];
    for (int i = 0; i < len; i++) {
        [p appendString:@"●"];
    }
    mValueLabel.text = p;
    [p release];

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
