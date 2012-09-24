// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "AppDelegate.h"
#import "ConfigViewController.h"
#import "Config.h"
#import "GenSelectListVC.h"
#import "CategoryListVC.h"
#import "PinController.h"
#import "DropboxBackup.h"

@implementation ConfigViewController

- (id)init
{
    self = [super initWithNibName:@"ConfigView" bundle:nil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //[AppDelegate trackPageview:@"/ConfigViewController"];
    
    self.navigationItem.title = _L(@"Config");

    self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc]
             initWithBarButtonSystemItem:UIBarButtonSystemItemDone
             target:self
             action:@selector(doneAction:)];
}

- (void)doneAction:(id)sender
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

#if 0
- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section
{
    return _L(@"Config");
}
#endif

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 4;
    }
        
    return 1;
}

#define ROW_DATE_TIME_MODE 0
#define ROW_START_OF_WEEK 1
#define ROW_CUTOFF_DATE 2
#define ROW_CURRENCY 3

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    static NSString *cellid = @"ConfigCell";

    cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellid];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.imageView.image = nil;
    
    Config *config = [Config instance];

    NSString *text = nil;
    NSString *detailText = @"";

    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case ROW_DATE_TIME_MODE:
                    text = _L(@"Date style");
                    switch (config.dateTimeMode) {
                        case DateTimeModeWithTime:
                            detailText = _L(@"Date and time (1 min)");
                            break;
                        case DateTimeModeWithTime5min:
                            detailText = _L(@"Date and time (5 min)");
                            break;
                        default:
                            detailText = _L(@"Date only");                            
                            break;
                    }
                    break;

                case ROW_START_OF_WEEK:
                    text = _L(@"Start of week");
                    if (config.startOfWeek == 0) {
                        detailText = _L(@"Sunday");
                    } else {
                        detailText = _L(@"Monday");
                    }
                    break;
                    
                case ROW_CUTOFF_DATE:
                    text = _L(@"Cutoff date");
                    if (config.cutoffDate == 0) {
                        detailText = _L(@"End of month");
                    } else {
                        detailText = [NSString stringWithFormat:@"%d", config.cutoffDate];
                    }
                    break;
                    
                case ROW_CURRENCY:
                    text = _L(@"Currency");
                    NSString *currency = [[CurrencyManager instance] baseCurrency];
                    if (currency == nil) {
                        currency = @"System";
                    }
                    detailText = currency;
                    break;
            }
            break;
            
        case 1:
            text = _L(@"Edit Categories");
            break;
            
        case 2:
            text = _L(@"Set PIN Code");
            break;
            
        case 3:
            text = _L(@"Unlink dropbox account");
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            NSString *path = [[NSBundle mainBundle] pathForResource:@"dropbox" ofType:@"png"];
            UIImage *image = [UIImage imageWithContentsOfFile:path];
            cell.imageView.image = image;
            break;
    }
    
    cell.textLabel.text = text;
    cell.detailTextLabel.text = detailText;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Config *config = [Config instance];

    GenSelectListViewController *gt = nil;
    NSMutableArray *typeArray;
    CategoryListViewController *categoryVC;
    PinController *pinController;
    DropboxBackup *dbb;

    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case ROW_DATE_TIME_MODE:
                    typeArray = [[NSMutableArray alloc] initWithObjects:
                                  _L(@"Date and time (1 min)"),
                                  _L(@"Date and time (5 min)"),
                                  _L(@"Date only"),
                                  nil];
                    gt = [GenSelectListViewController
                          genSelectListViewController:self
                          items:typeArray
                          title:_L(@"Date style")
                          identifier:ROW_DATE_TIME_MODE];
                    gt.selectedIndex = config.dateTimeMode;
                    break;

                case ROW_START_OF_WEEK:
                    typeArray = [[NSMutableArray alloc] initWithObjects:
                                  _L(@"Sunday"),
                                  _L(@"Monday"),
                                  nil];
                    gt = [GenSelectListViewController
                          genSelectListViewController:self
                          items:typeArray
                          title:_L(@"Start of week")
                          identifier:ROW_START_OF_WEEK];
                    gt.selectedIndex = config.startOfWeek;
                    break;
                    
                case ROW_CUTOFF_DATE:
                    typeArray = [[NSMutableArray alloc] init];
                    [typeArray addObject:_L(@"End of month")];
                    for (int i = 1; i <= 28; i++) {
                        [typeArray addObject:[NSString stringWithFormat:@"%d", i]];
                    }
                    gt = [GenSelectListViewController
                          genSelectListViewController:self
                          items:typeArray
                          title:_L(@"Cutoff date")
                          identifier:ROW_CUTOFF_DATE];
                    gt.selectedIndex = config.cutoffDate;
                    break;
                    
                case ROW_CURRENCY:
                    typeArray = [[NSMutableArray alloc] initWithArray:[[CurrencyManager instance] currencies]];
                    [typeArray insertObject:@"System" atIndex:0];
                    gt = [GenSelectListViewController
                          genSelectListViewController:self
                          items:typeArray
                          title:_L(@"Currency")
                          identifier:ROW_CURRENCY];
                    NSString *currency = [[CurrencyManager instance] baseCurrency];
                    gt.selectedIndex = 0;
                    if (currency != nil) {
                        for (int i = 1; i < [typeArray count]; i++) {
                            if ([currency isEqualToString:typeArray[i]]) {
                                gt.selectedIndex = i;
                                break;
                            }
                        }
                    }
                    break;
            }

            [self.navigationController pushViewController:gt animated:YES];
            break;
            
        case 1:
            categoryVC = [[CategoryListViewController alloc] init];
            categoryVC.isSelectMode = NO;
            [self.navigationController pushViewController:categoryVC animated:YES];
            break;
            
        case 2:
            pinController = [PinController pinController];
            [pinController modifyPin:self];
            break;
            
        case 3:
            dbb = [[DropboxBackup alloc] init:nil];
            [dbb unlink];
            break;
    }
}

- (BOOL)genSelectListViewChanged:(GenSelectListViewController *)vc identifier:(int)id
{
    Config *config = [Config instance];
    NSString *currency = nil;
    
    switch (id) {
        case ROW_DATE_TIME_MODE:
            config.dateTimeMode = vc.selectedIndex;
            break;

        case ROW_START_OF_WEEK:
            config.startOfWeek = vc.selectedIndex;
            break;

        case ROW_CUTOFF_DATE:
            config.cutoffDate = vc.selectedIndex;
            break;

        case ROW_CURRENCY:
            if (vc.selectedIndex > 0) {
                currency = (vc.items)[vc.selectedIndex];
            }
            [CurrencyManager instance].baseCurrency = currency;
            break;
    }

    [config save];
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (IS_IPAD) return YES;
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
