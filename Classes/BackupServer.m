// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <arpa/inet.h>
#import <fcntl.h>
#import <unistd.h>

#import "BackupServer.h"
#import "AppDelegate.h"

@implementation BackupServer

#define BACKUP_NAME @"CashflowBackup.sql"

- (void)requestHandler:(int)s filereq:(NSString*)filereq body:(char *)body bodylen:(int)bodylen
{
    // Request to '/' url.
    if ([filereq isEqualToString:@"/"])
    {
        [self sendIndexHtml:s];
    }

    // download
    else if ([filereq hasPrefix:@"/" BACKUP_NAME]) {
        [self sendBackup:s];
    }
            
    // upload
    else if ([filereq isEqualToString:@"/restore"]) {
        [self restore:s body:body bodylen:bodylen];
    }
}

/**
   Send top page
*/
- (void)sendIndexHtml:(int)s
{
    [self send:s string:@"HTTP/1.0 200 OK\r\nContent-Type: text/html\r\n\r\n"];

    [self send:s string:@"<html><body>"];
    [self send:s string:@"<h1>Backup</h1>"];
    [self send:s string:@"<form method=\"get\" action=\"/" BACKUP_NAME "\"><input type=submit value=\"Backup\"></form>"];

    [self send:s string:@"<h1>Restore</h1>"];
    [self send:s string:@"<form method=\"post\" enctype=\"multipart/form-data\"action=\"/restore\">"];
    [self send:s string:@"Select file to restore : <input type=file name=filename><br>"];
    [self send:s string:@"<input type=submit value=\"Restore\"></form>"];

    [self send:s string:@"</body></html>"];
}

/**
   Send backup file
*/
- (void)sendBackup:(int)s
{
    DataModel *m = [DataModel instance];
    NSString *path = [m getBackupSqlPath];

    if (![m backupDatabaseToSql:path]) {
        // write local file error...
        // TBD
        return;
    }

    int f = open([path UTF8String], O_RDONLY);
    if (f < 0) {
        // file open error...
        // TBD
        return;
    }

    [self send:s string:@"HTTP/1.0 200 OK\r\nContent-Type:application/octet-stream\r\n\r\n"];

    char buf[1024];
    for (;;) {
        int len = read(f, buf, sizeof(buf));
        if (len == 0) break;

        write(s, buf, len);
    }
    close(f);
}

/**
   Restore from backup file
*/
- (void)restore:(int)s body:(char *)body bodylen:(int)bodylen
{
    NSLog(@"%s", body);
    // get mimepart delimiter
    char *p = strstr(body, "\r\n");
    if (!p) return;
    *p = 0;
    char *delimiter = body;

    // find data start pointer
    p = strstr(p + 2, "\r\n\r\n");
    if (!p) return;
    char *start = p + 4;

    // find data end pointer
    char *end = NULL;
    int delimlen = strlen(delimiter);
    for (p = start; p < body + bodylen; p++) {
        if (strncmp(p, delimiter, delimlen) == 0) {
            end = p - 2; // previous new line
            break;
        }
    }
    if (!end) return;

    // Save data between start and end.
    DataModel *m = [DataModel instance];
    NSString *path = [m getBackupSqlPath];

    int f = open([path UTF8String], O_CREAT | O_WRONLY, 0644);
    if (f < 0) {
        // TBD;
        return;
    }

    p = start;
    while (p < end) {
        int len = write(f, p, end - p);
        p += len;
    }
    close(f);

    // restore
    if (![m restoreDatabaseFromSql:path]) {
        [self send:s string:@"HTTP/1.0 200 OK\r\nContent-Type:text/html\r\n\r\n"];
        [self send:s string:@"This is not cashflow backup file. Try again."];
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        return;
    }
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    
    // send reply
    [self send:s string:@"HTTP/1.0 200 OK\r\nContent-Type:text/html\r\n\r\n"];
    [self send:s string:@"Restore completed. Please restart the application."];

    // terminate application ...
    //[[UIApplication sharedApplication] terminate];
    //exit(0);
    
    // ロードを行う
    [[DataModel instance] load];
}

@end
