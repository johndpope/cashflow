// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "TransactionVC.h"
#import "EditDateVC.h"
#import "AppDelegate.h"
#import "Config.h"

@implementation EditDateViewController
{
    id<EditDateViewDelegate> __unsafe_unretained mDelegate;
    NSDate *mDate;
}

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
    
    self.title = _L(@"Date");
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                  initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                  target:self
                                                  action:@selector(doneAction)];

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
