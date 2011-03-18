// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#if 0 // NOT IN USE

#import <AudioToolbox/AudioToolbox.h>

#import "TransactionVC.h"
#import "EditValueVC.h"
#import "AppDelegate.h"

@implementation EditValueViewController

@synthesize delegate = mDelegate, value = mValue;

- (id)init
{
    self = [super initWithNibName:@"EditValueView" bundle:nil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    if (IS_IPAD) {
        CGSize s = self.contentSizeForViewInPopover;
        s.height = 480;
        self.contentSizeForViewInPopover = s;
    }
    
    self.title = _L(@"Amount")+
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
                                                  initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                  target:self
                                                  action:@selector(doneAction)] autorelease];

    numstr = [[NSMutableString alloc] initWithCapacity:16];
}

- (void)dealloc
{
    [numstr release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
    NSString *n;
    if (mValue == 0.0) {
        n = @"";
    } else if (mValue - (int)mValue == 0.0) {
        n = [NSString stringWithFormat:@"%.0f", mValue];
    } else {
        n = [NSString stringWithFormat:@"%.2f", mValue];
    }
    [numstr setString:n];
	
    [self updateLabel];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void)doneAction
{
    mValue = [numstr doubleValue];
    [mDelegate editValueViewChanged:self];

    [self.navigationController popViewControllerAnimated:YES];
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
        [numstr setString:@""];
    }
    else if (sender == button_BS) {
        // バックスペース
        len = numstr.length;
        if (len > 0) {
            [numstr deleteCharactersInRange:NSMakeRange(len-1, 1)];
            if ([numstr isEqualToString:@"0"]) {
                [numstr setString:@""];
            }
            if ([numstr isEqualToString:@"-"]) {
                [numstr setString:@""];
            }
        }
    }
    else if (sender == button_Period) {
        // ピリオド追加
        if ([numstr rangeOfString:@"."].location == NSNotFound) {
            ch = @".";
        }
    }
    else if (sender == button_inv) {
        // 符号反転
        if ([numstr length] == 0) {
            // do nothing
        } else if ([[numstr substringToIndex:1] isEqualToString:@"-"]) {
            [numstr deleteCharactersInRange:NSMakeRange(0, 1)];
        } else {
            [numstr insertString:@"-" atIndex:0];
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
        if ([numstr isEqualToString:@""]) {
            // special case
            if ([ch isEqualToString:@"0"]) {
                // do nothing
            } else if ([ch isEqualToString:@"."]) {
                [numstr setString:@"0."];
            } else {
                [numstr appendString:ch];
            }
        } else {
            [numstr appendString:ch];
        }
    }
	
    [self updateLabel];
}

- (void)updateLabel
{
    if (numstr.length == 0) {
        numLabel.text = @"0";
        return;
    }

    NSMutableString *tmp = [numstr mutableCopy];
    BOOL isMinus = NO;
    if ([[tmp substringToIndex:1] isEqualToString:@"-"]) {
        isMinus = YES;
    }
		
    // ピリオドの位置を探す
    NSRange range = [tmp rangeOfString:@"."];
    int i;
    if (range.location == NSNotFound) {
        i = tmp.length;
    } else {
        i = range.location;
    }

    // カンマを３桁ごとに挿入
    for (i -= 3 ; i > 0; i -= 3) {
        if (isMinus && i <= 1) break;
        [tmp insertString:@"," atIndex:i];
    }
	
    numLabel.text = tmp;
    [tmp release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (IS_IPAD) return YES;
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end

#endif

