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
{
    __weak id<BackupViewDelegate> _delegate;
    
    IBOutlet UILabel *_labelSync;
    IBOutlet UILabel *_labelUpload;
    IBOutlet UILabel *_labelDownload;
    IBOutlet UILabel *_labelBackupRestore;
    
    DBLoadingView *_loadingView;
    DropboxBackup *_dropboxBackup;
}

- (void)setDelegate:(id<BackupViewDelegate>)delegate
{
    _delegate = delegate;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[AppDelegate trackPageview:@"/BackupViewController"];

    [_labelSync setText:_L(@"Sync")];
    [_labelUpload setText:_L(@"Upload")];
    [_labelDownload setText:_L(@"Download")];
    [_labelBackupRestore setText:_L(@"Backup / Restore")];
    [_labelBackupRestore setText:[NSString stringWithFormat:@"%@ / %@",
                           _L(@"Backup"),
                           _L(@"Restore")]];
}

- (IBAction)doneAction:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
    [_delegate backupViewFinished:self];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"Dropbox";

        case 1:
            return _L(@"Internal web server");
    }
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    NSString *title;
    
    switch (section) {
        case 0:
            title = _L(@"The backup data will be stored as CashFlowBackup.sql in root folder of Dropbox.");
            return title;
    }
    return nil;
}

/*
// 行の内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"BackupViewCells";
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
    }

    NSString *imageName = nil;
    
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = _L(@"Sync");
                    imageName = @"dropboxSync";
                    break;
                    
                case 1:
                    //cell.textLabel.text = _L(@"Backup");
                    cell.textLabel.text = _L(@"Upload");
                    imageName = @"dropboxBackup";
                    break;
                    
                case 2:
                    //cell.textLabel.text = _L(@"Restore");
                    cell.textLabel.text = _L(@"Download");
                    imageName = @"dropboxRestore";
                    break;
            }
            break;
            
        case 1:
            cell.textLabel.text = [NSString stringWithFormat:@"%@ / %@",
                                   _L(@"Backup"),
                                   _L(@"Restore")];
            break;
    }
    
    if (imageName) {
        NSString *path = [[NSBundle mainBundle] pathForResource:imageName ofType:@"png"];
        cell.imageView.image = [UIImage imageWithContentsOfFile:path];
    }

    return cell;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    WebServerBackup *webBackup;
    UIAlertView *alertView;
    
    switch (indexPath.section) {
        case 0:
            // dropbox
            if (_dropboxBackup == nil) {
                _dropboxBackup = [[DropboxBackup alloc] init:self];
            }
            switch (indexPath.row) {
                case 0: // sync
                    [AppDelegate trackEvent:@"backup" action:@"dropbox" label:@"sync" value:nil];
                    [_dropboxBackup doSync:self];
                    break;
                    
                case 1: // backup
                    [AppDelegate trackEvent:@"backup" action:@"dropbox" label:@"backup" value:nil];
                    [_dropboxBackup doBackup:self];
                    break;
                    
                case 2: //restore
                    [AppDelegate trackEvent:@"backup" action:@"dropbox" label:@"restore" value:nil];
                    alertView = [[UIAlertView alloc] initWithTitle:_L(@"Warning")
                                                            message:_L(@"RestoreWarning")
                                                           delegate:self 
                                                  cancelButtonTitle:_L(@"Cancel")
                                                  otherButtonTitles:_L(@"OK"), nil];
                    [alertView show];
                    break;
            }
            break;

        case 1:
            // internal web server
            [AppDelegate trackEvent:@"backup" action:@"web" label:@"start" value:nil];
            webBackup = [WebServerBackup new];
            [webBackup execute];
            break;
    }
}

#pragma mark UIAlertViewDelegate protocol

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // リストア確認
    if (buttonIndex == 1) { // OK
        // UIAlertView が消えてからすぐに次の View (LoadingView) を表示すると、
        // 次の View が正しく表示されない。このため少し待たせる
        [_dropboxBackup performSelector:@selector(doRestore:) withObject:self afterDelay:0.5];
    }
}

#pragma mark DropboxBackupDelegate

- (void)dropboxBackupStarted:(int)mode
{
    NSLog(@"DropboxBackupStarted");
    
    NSString *msg = nil;
    switch (mode) {
        case MODE_SYNC:
            msg = _L(@"Syncing");
            break;

        case MODE_BACKUP:
            msg = _L(@"Uploading");
            break;
            
        case MODE_RESTORE:
            msg = _L(@"Downloading");
            break;
    }
    _loadingView = [[DBLoadingView alloc] initWithTitle:msg];
    _loadingView.userInteractionEnabled = YES; // 下の View の操作不可にする
    [_loadingView setOrientation:self.interfaceOrientation];
    [_loadingView show:self.view.window];
}

- (void)dropboxBackupFinished
{
    NSLog(@"DropboxBackupFinished");
    [_loadingView dismissAnimated:NO];
    _loadingView = nil;
}

// 衝突が発生した場合の処理
- (void)dropboxBackupConflicted
{
    NSLog(@"DropboxBackupConflicted");
    [_loadingView dismissAnimated:NO];
    _loadingView = nil;
    
    UIActionSheet *as =
    [[UIActionSheet alloc] initWithTitle:_L(@"sync_conflict")
                                delegate:self
                       cancelButtonTitle:_L(@"Cancel")
                  destructiveButtonTitle:nil
                       otherButtonTitles:_L(@"Use local (upload)"), _L(@"Use remote (download)"), nil];
    [as showInView:[self view]];
}

- (void)actionSheet:(UIActionSheet*)as clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [_dropboxBackup performSelector:@selector(doBackup:) withObject:self afterDelay:0.5];
            break;
            
        case 1:
            [_dropboxBackup performSelector:@selector(doRestore:) withObject:self afterDelay:0.5];
            break;
    }
}
    
#pragma mark utils

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return IS_IPAD || interfaceOrientation == UIInterfaceOrientationPortrait;
}

@end
