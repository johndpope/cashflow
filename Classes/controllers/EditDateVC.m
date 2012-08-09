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

@interface EditDateViewController ()
- (void)doneAction;
@end

@implementation EditDateViewController
{
    IBOutlet UIDatePicker *mDatePicker;
    IBOutlet UIButton *mCalendarButton;
    IBOutlet UIButton *mSetCurrentButton;
    
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
    
    [mCalendarButton setTitle:_L(@"Calendar") forState:UIControlStateNormal];
    [mSetCurrentButton setTitle:_L(@"Current Time") forState:UIControlStateNormal];
}


- (void)viewWillAppear:(BOOL)animated
{
    [mDatePicker setDate:self.date animated:NO];
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

- (IBAction)showCalendar:(id)sender {
    CalendarViewController *vc = [CalendarViewController new];
    vc.selectedDate = mDatePicker.date;
    [vc setCalendarViewControllerDelegate:self];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)setCurrentTime:(id)sender {
    self.date = [NSDate new]; // current time
    [mDatePicker setDate:self.date animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (IS_IPAD) return YES;
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark CalendarViewControllerDelegate
- (void)calendarViewController:(CalendarViewController *)aCalendarViewController dateDidChange:(NSDate *)aDate
{
    if (aDate == nil) return; // do nothing (Clear button)

    // 時刻を取り出す
    NSDateComponents *comps = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] 
                                components:(NSHourCalendarUnit | NSMinuteCalendarUnit) 
                                fromDate:mDatePicker.date];
    int hour = [comps hour];
    int min = [comps minute];
    
    // カレンダーで指定した日時(0:00) に以前の時刻の値を加算する
    self.date = [aDate dateByAddingTimeInterval:(hour * 3600 + min * 60)];

    // Si-Calendar は、選択時に自動で View を閉じない仕様なので、ここで閉じる
    [aCalendarViewController.navigationController popViewControllerAnimated:YES];
}

@end
