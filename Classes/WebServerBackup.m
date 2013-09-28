// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "WebServerBackup.h"
#import "BackupServer.h"
#import "AppDelegate.h"

@implementation WebServerBackup
{
    BackupServer *_backupServer;
}

static WebServerBackup *sWebServerBackup = nil;

- (void)execute
{
    BOOL result = NO;
    NSString *message = nil;
 
    sWebServerBackup = self;
    
    _backupServer = [BackupServer new];
    NSString *url = [_backupServer serverUrl];
    if (url != nil) {
        result = [_backupServer startServer];
    } else {
        message = _L(@"Network is unreachable.");
    }
    
    UIAlertView *v;
    if (!result) {
        if (message == nil) {
            message = _L(@"Cannot start web server.");
        }
        
        v = [[UIAlertView alloc]
             initWithTitle:@"Error"
             message:message
             delegate:nil cancelButtonTitle:_L(@"Dismiss")
             otherButtonTitles:nil];
    } else {
        message = [NSString stringWithFormat:_L(@"BackupNotation"), url];
        
        v = [[UIAlertView alloc]
             initWithTitle:_L(@"Backup and restore")
             message:message
             delegate:self cancelButtonTitle:_L(@"Dismiss")
             otherButtonTitles:nil];
    }
    [v show];
    
     // release in alert view delegate
}

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [_backupServer stopServer];
    _backupServer = nil;

    // release
    sWebServerBackup = nil;
}

@end
