//
//  CFCalendarViewController.m
//

#import "AppDelegate.h"
#import "CFCalendarViewController.h"

@implementation CFCalendarViewController

@synthesize delegate, selectedDate;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = _L(@"Calendar");
    [[self.navigationController navigationBar] setTranslucent:NO];

    UIBarButtonItem *todayButton = [[UIBarButtonItem alloc]
            initWithTitle:@"Today"
                    style:UIBarButtonItemStylePlain
                   target:self
                   action:@selector(today)];
    [self.navigationItem setRightBarButtonItem:todayButton];
    
    // 指定された日付を CalendarView に設定
    self.calendarView.selectedDate = self.selectedDate;
}

// 日付選択
- (void)calendarView:(RDVCalendarView *)calendarView didSelectDate:(NSDate *)date
{
    NSLog(@"date selected : %@", date);
    self.selectedDate = date;
    [self.delegate cfcalendarViewController:self didSelectDate:date];
}

// 今日を選択
- (void)today
{
    self.selectedDate = [NSDate new];
    [self.delegate cfcalendarViewController:self didSelectDate:self.selectedDate];
}


@end
