// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "DBLoadingView.h"
#import "DropboxBackup.h"

@class BackupViewController;

@protocol BackupViewDelegate
- (void)backupViewFinished:(BackupViewController *)backupViewController;
@end

@interface BackupViewController : UITableViewController <DropboxBackupDelegate, UIAlertViewDelegate, UIActionSheetDelegate>
{
    id<BackupViewDelegate> mDelegate;

    DBLoadingView *mLoadingView;
    DropboxBackup *mDropboxBackup;
}

+ (BackupViewController *)backupViewController:(id<BackupViewDelegate>)delegate;

- (void)setDelegate:(id<BackupViewDelegate>)delegate;
- (void)doneAction:(id)sender;

@end
