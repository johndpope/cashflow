// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "AppDelegate.h"
#import "BackupVC.h"
#import "DropboxBackup.h"
#import "WebServerBackup.h"

@implementation BackupViewController

+ (BackupViewController *)backupViewController
{
    BackupViewController *vc =
        [[[BackupViewController alloc] initWithNibName:@"BackupView" bundle:nil] autorelease];
    return vc;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem =
        [[[UIBarButtonItem alloc]
          initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)] autorelease];
}

- (void)doneAction:(id)sender
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)dealloc
{
    [mDropboxBackup release];
    [super dealloc];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"Dropbox";

        case 1:
            return NSLocalizedString(@"Internal web server", @"");
    }
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"The backup data will be stored as CashFlowBackup.db in root folder of Dropbox.";
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            // dropbox : backup and restore
            return 3;
            
        case 1:
            // internal web backup
            return 1;
    }
    return 0;
}

// 行の内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *MyIdentifier = @"BackupViewCells";
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier] autorelease];
    }

    
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = NSLocalizedString(@"Backup", @"");
                    break;
                    
                case 1:
                    cell.textLabel.text = NSLocalizedString(@"Restore", @"");
                    break;
                    
                case 2:
                    cell.textLabel.text = NSLocalizedString(@"Unlink dropbox account", @"");
                    break;
            }
            break;
            
        case 1:
            cell.textLabel.text = [NSString stringWithFormat:@"%@ / %@",
                                   NSLocalizedString(@"Backup", @""),
                                   NSLocalizedString(@"Restore", @"")];
            break;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    WebServerBackup *webBackup;
    UIAlertView *alertView;
    
    switch (indexPath.section) {
        case 0:
            // dropbox
            if (mDropboxBackup == nil) {
                mDropboxBackup = [[DropboxBackup alloc] init:self];
            }
            switch (indexPath.row) {
                case 0: // backup
                    [mDropboxBackup doBackup:self];
                    break;
                    
                case 1: //restore
                    alertView = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", @"")
                                                            message:NSLocalizedString(@"RestoreWarning", @"")
                                                           delegate:self 
                                                  cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                                  otherButtonTitles:NSLocalizedString(@"Ok", @""), nil] autorelease];
                    [alertView show];
                    break;
                    
                case 2: // unlink dropbox account
                    [mDropboxBackup unlink];
                    break;
            }
            break;

        case 1:
            // internal web server
            webBackup = [[[WebServerBackup alloc] init] autorelease];
            [webBackup execute];
            break;
    }
}

#pragma mark UIAlertViewDelegate protocol

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) { // OK
        // UIAlertView が消えてからすぐに次の View (LoadingView) を表示すると、
        // 次の View が正しく表示されない。このため少し待たせる
        [mDropboxBackup performSelector:@selector(doRestore:) withObject:self afterDelay:0.5];
    }
}

#pragma mark DropboxBackupDelegate

- (void)dropboxBackupStarted
{
    NSLog(@"DropboxBackupStarted");
    mLoadingView = [[DBLoadingView alloc] initWithTitle:nil];
    mLoadingView.userInteractionEnabled = YES; // 下の View の操作不可にする
    [mLoadingView show];
}

- (void)dropboxBackupFinished
{
    NSLog(@"DropboxBackupFinished");
    [mLoadingView dismissAnimated:NO];
    [mLoadingView release];
    mLoadingView = nil;
}

#pragma mark utils

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (IS_IPAD) return YES;
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
