// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>
#import "DataModel.h"

@protocol DropboxBackupDelegate
- (void)dropboxBackupStarted:(BOOL)isRestore;
- (void)dropboxBackupFinished;
@end

@interface DropboxBackup : NSObject <DBRestClientDelegate, DataModelDelegate>
{
    id<DropboxBackupDelegate> mDelegate;
    
    UIViewController *mViewController;
    DBRestClient *mRestClient;
    int mMode;
    
    // リモートのリビジョン
    NSString *mRemoteRev;
    
    // 前回の同期以降、ローカル DB が変更されているかどうか
    BOOL mIsLocalModified;
}

@property(readonly) DBRestClient *restClient;

- (id)init:(id<DropboxBackupDelegate>)delegate;

- (void)doBackup:(UIViewController *)viewController;
- (void)doRestore:(UIViewController *)viewController;
- (void)unlink;

@end
