// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

#import "DropboxSDK.h"
#import "DBLoadingView.h"

#import "ExportServer.h"
#import "Asset.h"

#define REPLACE(from, to) \
  [str replaceOccurrencesOfString: from withString: to \
  options:NSLiteralSearch range:NSMakeRange(0, [str length])]
	
@interface ExportBase : NSObject <UIAlertViewDelegate, MFMailComposeViewControllerDelegate, DBLoginControllerDelegate, DBRestClientDelegate> {
    NSDate *mFirstDate;
    NSArray *mAssets;

    ExportServer *mWebServer;
    
    // for dropbox
    DBRestClient *mRestClient;
    DBLoadingView *mLoadingView;
}

@property(nonatomic,retain) NSDate *firstDate;
@property(nonatomic,assign) NSArray *assets;

@property(nonatomic,readonly) DBRestClient *restClient;

// public methods
- (BOOL)sendMail:(UIViewController*)parent;
- (BOOL)sendToDropbox:(UIViewController*)parent;
- (BOOL)sendWithWebServer;

// You must override following methods
- (NSString *)mailSubject;
- (NSString*)fileName;
- (NSString *)mimeType;
- (NSString *)contentType;
- (NSData*)generateBody;

// internal
- (void)_sendToDropbox;
- (void)_showResult:(NSString *)message;

@end

