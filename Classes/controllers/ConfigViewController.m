// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "CashFlow-Swift.h"

#import "AppDelegate.h"
#import "ConfigViewController.h"
#import "Config.h"
#import "GenSelectListVC.h"
#import "CategoryListVC.h"
#import "PinController.h"
#import "DropboxBackup.h"

@implementation ConfigViewController
{
    __weak IBOutlet UILabel *dateFormatLabel;
    __weak IBOutlet UILabel *dateFormatDescLabel;
    __weak IBOutlet UILabel *weekStartLabel;
    __weak IBOutlet UILabel *weekStartDescLabel;
    __weak IBOutlet UILabel *cutoffDateLabel;
    __weak IBOutlet UILabel *cutoffDateDescLabel;
    __weak IBOutlet UILabel *currencyLabel;
    __weak IBOutlet UILabel *currencyDescLabel;
    __weak IBOutlet UILabel *editCategoryLabel;
    __weak IBOutlet UILabel *passcodeLabel;
    __weak IBOutlet UILabel *resetDropboxLabel;
    
    __weak IBOutlet UISwitch *passcodeSwitch;
    __weak IBOutlet UISwitch *touchIdSwitch;
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
    
    [self setupLabels];
}

- (IBAction)doneAction:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

/**
 * パスコード設定スイッチ変更
 */
- (IBAction)passcodeSwitchChanged:(id)sender {
    PinController *pinController = [PinController sharedController];

    if (passcodeSwitch.on) {
        // パスコード設定
        pinController = [PinController sharedController];
        [pinController modifyPin:self];
    } else {
        // パスコード解除
        [pinController deletePin];
    }
}

- (IBAction)touchIdSwitchChanged:(id)sender {
    Config *config = [Config instance];
    config.useTouchId = touchIdSwitch.on;
    [config save];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupLabels];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark Table view methods

#define ROW_DATE_TIME_MODE 0
#define ROW_START_OF_WEEK 1
#define ROW_CUTOFF_DATE 2
#define ROW_CURRENCY 3

- (void)setupLabels
{
    Config *config = [Config instance];
    PinController *pinController = [PinController sharedController];
    
    dateFormatLabel.text = _L(@"Date style");
    switch (config.dateTimeMode) {
        case DateTimeModeWithTime:
            dateFormatDescLabel.text = _L(@"Date and time (1 min)");
            break;
        case DateTimeModeWithTime5min:
            dateFormatDescLabel.text = _L(@"Date and time (5 min)");
            break;
        default:
            dateFormatDescLabel.text = _L(@"Date only");
            break;
    }
    
    weekStartLabel.text = _L(@"Start of week");
    if (config.startOfWeek == 0) {
        weekStartDescLabel.text = _L(@"Sunday");
    } else {
        weekStartDescLabel.text = _L(@"Monday");
    }
                    
    cutoffDateLabel.text = _L(@"Cutoff date");
    if (config.cutoffDate == 0) {
        cutoffDateDescLabel.text = _L(@"End of month");
    } else {
        cutoffDateDescLabel.text = [NSString stringWithFormat:@"%ld", (long)config.cutoffDate];
    }

    currencyLabel.text = _L(@"Currency");
    NSString *currency = [[CurrencyManager instance] baseCurrency];
    if (currency == nil) {
        currency = @"System";
    }
    currencyDescLabel.text = currency;

    editCategoryLabel.text = _L(@"Edit Categories");

    passcodeLabel.text = _L(@"Set passcode");
    
    resetDropboxLabel.text = _L(@"Unlink dropbox account");

    passcodeSwitch.on = pinController.pin != nil;
    touchIdSwitch.on = config.useTouchId;
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
                    typeArray = [@[_L(@"Date and time (1 min)"), _L(@"Date and time (5 min)"), _L(@"Date only")] mutableCopy];
                    gt = [GenSelectListViewController
                          genSelectListViewController:self
                          items:typeArray
                          title:_L(@"Date style")
                          identifier:ROW_DATE_TIME_MODE];
                    gt.selectedIndex = config.dateTimeMode;
                    break;

                case ROW_START_OF_WEEK:
                    typeArray = [@[_L(@"Sunday"), _L(@"Monday")] mutableCopy];
                    gt = [GenSelectListViewController
                          genSelectListViewController:self
                          items:typeArray
                          title:_L(@"Start of week")
                          identifier:ROW_START_OF_WEEK];
                    gt.selectedIndex = config.startOfWeek;
                    break;
                    
                case ROW_CUTOFF_DATE:
                    typeArray = [NSMutableArray new];
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
            categoryVC = [CategoryListViewController new];
            categoryVC.isSelectMode = NO;
            [self.navigationController pushViewController:categoryVC animated:YES];
            break;
            
        case 2:
            //pinController = [PinController sharedController];
            //[pinController modifyPin:self];
            break;
            
        case 3:
            dbb = [[DropboxBackup alloc] init:nil];
            [dbb unlink];
            break;
    }
}

- (BOOL)genSelectListViewChanged:(GenSelectListViewController *)vc identifier:(NSInteger)id
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
    return IS_IPAD || interfaceOrientation == UIInterfaceOrientationPortrait;
}

@end
