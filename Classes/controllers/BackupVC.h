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

@interface BackupViewController : UITableViewController <DropboxBackupDelegate, UIAlertViewDelegate>
{
    DBLoadingView *mLoadingView;
    DropboxBackup *mDropboxBackup;
}

+ (BackupViewController *)backupViewController;

- (void)doneAction:(id)sender;

@end
