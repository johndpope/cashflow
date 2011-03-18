// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import "DropboxSDK.h"
#import "DataModel.h"

@protocol DropboxBackupDelegate
- (void)dropboxBackupStarted:(BOOL)isRestore;
- (void)dropboxBackupFinished;
@end

@interface DropboxBackup : NSObject <DBRestClientDelegate, DBLoginControllerDelegate, DataModelDelegate>
{
    id<DropboxBackupDelegate> mDelegate;
    
    UIViewController *mViewController;
    DBRestClient *mRestClient;
    int mMode;
}

@property(readonly) DBRestClient *restClient;

- (id)init:(id<DropboxBackupDelegate>)delegate;

- (void)doBackup:(UIViewController *)viewController;
- (void)doRestore:(UIViewController *)viewController;
- (void)unlink;

- (void)_login;
- (void)_exec;
- (void)_showResult:(NSString *)message;

@end
