// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "DropboxBackup.h"
#import "Database.h"
#import "AppDelegate.h"

#import <TargetConditionals.h>

#if TARGET_IPHONE_SIMULATOR
#define	BACKUP_FILENAME	@"CashFlowBackup-simulator.sql"
#else
#define	BACKUP_FILENAME	@"CashFlowBackup.sql"
#endif

#define BACKUP_DIR      @"/"
#define BACKUP_FULLPATH BACKUP_DIR BACKUP_FILENAME

@implementation DropboxBackup
{
    id<DropboxBackupDelegate> mDelegate;
    
    DBRestClient *mRestClient;
    UIViewController *mViewController;
    int mMode;
    
    // リモートのリビジョン
    NSString *mRemoteRev;
    
    // 前回の同期以降、ローカル DB が変更されているかどうか
    BOOL mIsLocalModified;
}

- (id)init:(id<DropboxBackupDelegate>)delegate
{
    self = [super init];
    if (self) {
        mDelegate = delegate;
    }
    return self;
}

- (void)doSync:(UIViewController *)viewController
{
    mMode = MODE_SYNC;
    mViewController = viewController;
    [self _login:viewController];
}

- (void)doBackup:(UIViewController *)viewController
{
    mMode = MODE_BACKUP;
    mViewController = viewController;
    [self _login:viewController];
}

- (void)doRestore:(UIViewController *)viewController
{
    mMode = MODE_RESTORE;
    mViewController = viewController;
    [self _login:viewController];
}

- (void)unlink
{
    DBSession *session = [DBSession sharedSession];
    if ([session isLinked]) {
        [session unlinkAll];
    }

    [self _showResult:@"Your dropbox account has been unlinked"];
}

- (void)_login:(UIViewController *)vc
{
    DBSession *session = [DBSession sharedSession];
    
    // ログイン処理
    if (![session isLinked]) {
        // 未ログイン
        [session linkFromController:vc];
    } else {
        // ログイン済み
        [self _exec];
    }
}

- (void)_exec
{
    mIsLocalModified = [[DataModel instance] isModifiedAfterSync];
    
    // 現在のバージョンを取得する
    [self.restClient loadRevisionsForFile:BACKUP_FULLPATH];
    
    [mDelegate dropboxBackupStarted:mMode];
}

- (DBRestClient *)restClient
{
    if (mRestClient == nil) {
    	mRestClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    	mRestClient.delegate = self;
    }
    return mRestClient;
}

#pragma mrk DBRestClientDelegate

// バージョン取得
- (void)restClient:(DBRestClient *)client loadedRevisions:(NSArray *)revisions forFile:(NSString *)path
{
    if (![path isEqualToString:BACKUP_FULLPATH]) return;
    
    // 最新版のリビジョンを保存
    for (DBMetadata *m in revisions) {
        NSLog(@"revision: %lld %@", m.revision, m.rev);
    }
    DBMetadata *file = revisions[0];
    mRemoteRev = file.rev;
    
    BOOL isRemoteModified = [[DataModel instance] isRemoteModifiedAfterSync:mRemoteRev];
    
    switch (mMode) {
        case MODE_SYNC:
            if (mIsLocalModified && isRemoteModified) {
                // 衝突
                [mDelegate dropboxBackupConflicted];
            } else if (mIsLocalModified) {
                // upload
                [self _uploadBackupWithParentRev:mRemoteRev];
            } else if (isRemoteModified) {
                // download
                [self.restClient loadFile:BACKUP_FULLPATH intoPath:[[DataModel instance] getBackupSqlPath]];
            } else {
                // no need to sync
                [self _showResult:_L(@"no_need_to_sync")];
                [mDelegate dropboxBackupFinished];
            }
            break;
            
        case MODE_BACKUP:
            [self _uploadBackupWithParentRev:mRemoteRev];
            break;
            
        case MODE_RESTORE:
            [self.restClient loadFile:BACKUP_FULLPATH intoPath:[[DataModel instance] getBackupSqlPath]];
            break;
    }
}

// バージョン取得失敗 (ファイルなし)
- (void)restClient:(DBRestClient *)client loadRevisionsFailedWithError:(NSError *)error
{
    mRemoteRev = nil;
    
    switch (mMode) {
        case MODE_BACKUP:
        case MODE_SYNC:
            [self _uploadBackupWithParentRev:nil];
            break;
            
        case MODE_RESTORE:
            [self.restClient loadFile:BACKUP_FULLPATH intoPath:[[DataModel instance] getBackupSqlPath]];
            break;
    }
}

// バックアップファイルをアップロードする
- (void)_uploadBackupWithParentRev:(NSString *)rev
{
    DataModel *m = [DataModel instance];
    NSString *backupPath = [m getBackupSqlPath];

    if (![m backupDatabaseToSql:backupPath]) {
        [self _showResult:@"Cannot create backup data. Storage full?"];
        return;
    }

    // start backup
    NSLog(@"uploading file: %@", backupPath);
    [self.restClient uploadFile:BACKUP_FILENAME
                         toPath:BACKUP_DIR
                  withParentRev:rev
                       fromPath:backupPath];
}

// backup finished
- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath from:(NSString*)srcPath metadata:(DBMetadata *)metadata
{
    DataModel *dm = [DataModel instance];
    
    [[NSFileManager defaultManager] removeItemAtPath:[dm getBackupSqlPath] error:nil];

    if ([metadata.path isEqualToString:BACKUP_FULLPATH]) {
        NSLog(@"upload success: new rev : %lld %@", metadata.revision, metadata.rev);
    
        // 同期情報を保存
        [dm setLastSyncRemoteRev:metadata.rev];
        [dm setSyncFinished];
    
        [self _showResult:_L(@"upload_done")];
    } else {
        // バックアップファイル名が変わってしまっている
        // ⇒ 同時バックアップのため衝突が発生
        NSLog(@"upload failed because of conflict");
        [self _showResult:_L(@"upload_failed")];
    }
    [mDelegate dropboxBackupFinished];
}

// backup failed
- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error
{
    [self _showResult:_L(@"upload_failed")];
    [mDelegate dropboxBackupFinished];
}

// restore done
- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)destPath
{
    // SQL から書き戻す
    DataModel *dm = [DataModel instance];
    NSString *path = [dm getBackupSqlPath];

    BOOL result = [dm restoreDatabaseFromSql:path];
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    if (!result) {
        [self _showResult:_L(@"download_failed")];
        [mDelegate dropboxBackupFinished];
        return;
    }

    // 同期情報を保存
    [dm setLastSyncRemoteRev:mRemoteRev];
    [dm setSyncFinished];
     
    [self _showResult:_L(@"download_done")];
    [dm startLoad:self];
}

// restore failed
- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error
{
    [self _showResult:_L(@"download_failed")];
    [[DataModel instance] startLoad:self];
}

- (void)_showResult:(NSString *)message
{
    [[[UIAlertView alloc] 
       initWithTitle:@"Dropbox" message:message
       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
        show];
}

- (void)dataModelLoaded
{
    [mDelegate dropboxBackupFinished];
}

@end
