// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "AppDelegate.h"
#import "TransactionListVC.h"
#import "DataModel.h"
#import "Transaction.h"
#import "PinController.h"
#import "CrashReportSender.h"
#import "DropboxSDK.h"

#import "DropboxSecret.h"

@interface AppDelegate() <CrashReportSenderDelegate>
@end

@implementation AppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize splitViewController;

- (id)init {
    self = [super init];
    return self;
}

//
// 開始処理
//
- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    NSLog(@"applicationDidFinishLaunching");
    _application = application;

    // send crash report
    NSURL *reportUrl = [NSURL URLWithString:@"http://itemshelf.com/cgi-bin/crashreport.cgi"];
    [[CrashReportSender sharedCrashReportSender] 
        sendCrashReportToURL:reportUrl
        delegate:self 
        activateFeedback:NO];
    
    // Dropbox config
    DBSession *dbSession =
        [[[DBSession alloc]
             initWithConsumerKey:DROPBOX_CONSUMER_KEY
                  consumerSecret:DROPBOX_CONSUMER_SECRET]
            autorelease];
    dbSession.delegate = self;
    [DBSession setSharedSession:dbSession];

    // Configure and show the window
    [window makeKeyAndVisible];
    if (IS_IPAD) {
        [window addSubview:splitViewController.view];
    } else {
        [window addSubview:[navigationController view]];
    }

    // PIN チェック
    [self checkPin];
    
    // 乱数初期化
    srand([[NSDate date] timeIntervalSinceReferenceDate]);
    
    NSLog(@"applicationDidFinishLaunching: done");
}

// Background から復帰するときの処理
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [self checkPin];
}

- (void)checkPin
{
    PinController *pinController = [PinController pinController];
    if (pinController != nil) {
        if (IS_IPAD) {
            [pinController firstPinCheck:splitViewController];
        } else {
            [pinController firstPinCheck:navigationController];
        }    
    }
}


//
// 終了処理 : データ保存
//
- (void)applicationWillTerminate:(UIApplication *)application
{
    [DataModel finalize];
    [Database shutdown];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    //[DataModel finalize];
    //[Database shutdown];
}

- (void)dealloc {
    [navigationController release];
    [window release];
    [super dealloc];
}

#pragma mark CrashReportSenderDelegate

-(void)connectionOpened
{
    _application.networkActivityIndicatorVisible = YES;
}


-(void)connectionClosed
{
    _application.networkActivityIndicatorVisible = NO;
}


#pragma mark DBSessionDelegate methods

- (void)sessionDidReceiveAuthorizationFailure:(DBSession*)session
{
    DBLoginController* loginController = [[DBLoginController new] autorelease];
    if (IS_IPAD) {
        [loginController presentFromController:splitViewController]; // # TBD
    } else {
        [loginController presentFromController:navigationController];
    }        
}


#pragma mark Debug

void AssertFailed(const char *filename, int lineno)
{
    UIAlertView *v = [[UIAlertView alloc]
                         initWithTitle:@"Assertion Failed"
                         message:[NSString stringWithFormat:@"%@ line %d", 
                                  [NSString stringWithCString:filename encoding:NSUTF8StringEncoding] , lineno]
                         delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
    [v show];
    [v release];
}

@end
