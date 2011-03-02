// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
  CashFlow for iPhone/iPod touch

  Copyright (c) 2008, Takuya Murakami, All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are
  met:

  1. Redistributions of source code must retain the above copyright notice,
  this list of conditions and the following disclaimer. 

  2. Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution. 

  3. Neither the name of the project nor the names of its contributors
  may be used to endorse or promote products derived from this software
  without specific prior written permission. 

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/


#import "TransactionVC.h"
#import "EditDateVC.h"
#import "AppDelegate.h"
#import "Config.h"

@implementation EditDateViewController

@synthesize delegate = mDelegate, date = mDate;

- (id)init
{
    self = [super initWithNibName:@"EditDateView" bundle:nil];
    return self;
}

- (void)viewDidLoad
{
    if (IS_IPAD) {
        CGSize s = self.contentSizeForViewInPopover;
        s.height = 360;
        self.contentSizeForViewInPopover = s;
    }
    
    self.title = NSLocalizedString(@"Date", @"");
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
                                                  initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                  target:self
                                                  action:@selector(doneAction)] autorelease];

    if ([Config instance].dateTimeMode == DateTimeModeDateOnly) {
        mDatePicker.datePickerMode = UIDatePickerModeDate;
    } else {
        mDatePicker.datePickerMode = UIDatePickerModeDateAndTime;
        mDatePicker.minuteInterval = 1;
        if ([Config instance].dateTimeMode == DateTimeModeWithTime5min) {
            mDatePicker.minuteInterval = 5;
        }
    }
    
    [mDatePicker setTimeZone:[NSTimeZone systemTimeZone]];
}

- (void)dealloc
{
    [mDate release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    mDatePicker.date = self.date;
    [super viewWillAppear:animated];
}

- (void)doneAction
{
    self.date = mDatePicker.date;
    [mDelegate editDateViewChanged:self];

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (IS_IPAD) return YES;
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
