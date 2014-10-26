//
//  CFCalendarViewController.m
//

#import "AppDelegate.h"
#import "CFCalendarViewController.h"

@implementation CFCalendarViewController

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = _L(@"Calendar");
    [[self.navigationController navigationBar] setTranslucent:NO];

    UIBarButtonItem *todayButton = [[UIBarButtonItem alloc]
            initWithTitle:@"Today"
                    style:UIBarButtonItemStylePlain
                   target:[self calendarView]
                   action:@selector(showCurrentMonth)];
    [self.navigationItem setRightBarButtonItem:todayButton];
}

- (void)calendarView:(RDVCalendarView *)calendarView didSelectDate:(NSDate *)date
{
    NSLog(@"date selected : %@", date);
    [self.delegate cfcalendarViewController:self didSelectDate:date];
}


@end
