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
#define	BACKUP_FILENAME	@"CashFlowBackup-simulator.db"
#else
#define	BACKUP_FILENAME	@"CashFlowBackup.db"
#endif

#define MODE_BACKUP 0
#define MODE_RESTORE 1

@implementation DropboxBackup

- (id)init:(id<DropboxBackupDelegate>)delegate
{
    self = [super init];
    if (self) {
        mDelegate = delegate;
    }
    return self;
}


- (void)doBackup:(UIViewController *)viewController
{
    mMode = MODE_BACKUP;
    mViewController = viewController;
    [self _login];
}

- (void)doRestore:(UIViewController *)viewController
{
    mMode = MODE_RESTORE;
    mViewController = viewController;
    [self _login];
}

- (void)unlink
{
    DBSession *session = [DBSession sharedSession];
    if ([session isLinked]) {
        [session unlinkAll];
    }

    [self _showResult:@"Your dropbox account has been unlinked"];
}

- (void)_login
{
    DBSession *session = [DBSession sharedSession];
    
    // ログイン処理
    if (![session isLinked]) {
        // 未ログイン
        [session link];
    } else {
        // ログイン済み
        [self _exec];
    }
}

- (void)_exec
{
    NSString *dbPath = [[Database instance] dbPath:DBNAME];

    if (mMode == MODE_BACKUP) {
        // 現在のバージョンを取得する
        [self.restClient loadRevisionsForFile:@"/" BACKUP_FILENAME];
        //[self.restClient loadMetadata:@"/" BACKUP_FILENAME];
        [mDelegate dropboxBackupStarted:NO];
    }
    else if (mMode == MODE_RESTORE) {
        // shutdown database
        [DataModel finalize];
        [self.restClient loadFile:@"/" BACKUP_FILENAME intoPath:dbPath];
        [mDelegate dropboxBackupStarted:YES];
    }
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

// Backup : 現在のファイルバージョン取得
- (void)restClient:(DBRestClient *)client loadedRevisions:(NSArray *)revisions forFile:(NSString *)path
{
    if (mMode == MODE_BACKUP && [path isEqualToString:@"/" BACKUP_FILENAME]) {
        for (DBMetadata *m in revisions) {
            NSLog(@"revision: %lld %@", m.revision, m.rev);
        }
        
        DBMetadata *file = [revisions objectAtIndex:0];
        [self _uploadBackupWithParentRev:file.rev];
    }
}

- (void)restClient:(DBRestClient *)client loadRevisionsFailedWithError:(NSError *)error
{
    // 前リビジョンなし
    if (mMode == MODE_BACKUP) {
        [self _uploadBackupWithParentRev:nil];
    }
}

- (void)_uploadBackupWithParentRev:(NSString *)rev
{
    // start backup
    NSString *dbPath = [[Database instance] dbPath:DBNAME];
    [self.restClient uploadFile:BACKUP_FILENAME
                         toPath:@"/"
                  withParentRev:rev
                       fromPath:dbPath];
}

// backup finished
- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath from:(NSString*)srcPath metadata:(DBMetadata *)metadata
{
    NSLog(@"upload success: new rev : %lld %@", metadata.revision, metadata.rev);
    [self _showResult:@"Backup done."];
    [mDelegate dropboxBackupFinished];
}

// backup failed
- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error
{
    [self _showResult:@"Backup failed!"];
    [mDelegate dropboxBackupFinished];
}

// restore done
- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)destPath
{
    [self _showResult:@"Restore done."];
    [[DataModel instance] startLoad:self];
}

// restore failed
- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error
{
    [self _showResult:@"Restore failed!"];
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
