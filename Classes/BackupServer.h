// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "WebServer.h"

/**
   Web server for backup and restore
*/
@interface BackupServer : WebServer

- (void)sendIndexHtml:(int)s;
- (void)sendBackup:(int)s;
- (void)restore:(int)s body:(char*)body bodylen:(int)bodylen;

@end
