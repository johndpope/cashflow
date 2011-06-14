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
#import "GANTracker.h"

#import "DropboxSecret.h"

@interface AppDelegate() <CrashReportSenderDelegate>
@end

@implementation AppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize splitViewController;

static BOOL sIsPrevCrashed;

+ (BOOL)isPrevCrashed
{
    return sIsPrevCrashed;
}

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
    CrashReportSender *csr = [CrashReportSender sharedCrashReportSender];
    if ([csr hasPendingCrashReport]) {
        // 前回クラッシュしている
        sIsPrevCrashed = YES;
        [csr sendCrashReportToURL:reportUrl delegate:self activateFeedback:NO];
    } else {
        sIsPrevCrashed = NO;
    }
    
    // Dropbox config
    DBSession *dbSession =
        [[[DBSession alloc]
             initWithConsumerKey:DROPBOX_CONSUMER_KEY
                  consumerSecret:DROPBOX_CONSUMER_SECRET]
            autorelease];
    dbSession.delegate = self;
    [DBSession setSharedSession:dbSession];
    
    // Google analytics
    GANTracker *tracker = [GANTracker sharedTracker];
    NSString *ua;
#if FREE_VERSION
    ua = @"UA-413697-22";
#else
    ua = @"UA-413697-23";
#endif
    [tracker startTrackerWithAccountID:ua dispatchPeriod:60 delegate:nil];
    
    UIDevice *dev = [UIDevice currentDevice];
    [tracker trackPageview:[NSString stringWithFormat:@"/device/model/%@", [dev model]] withError:nil];
    [tracker trackPageview:[NSString stringWithFormat:@"/device/version/%@", [dev systemVersion]] withError:nil];

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

// Background に入る前の処理
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Background に入るまえに PIN コード表示を行っておく
    // 復帰時だと、前の画面が一瞬表示されたあとで PIN 画面がでてしまうので遅い
    [self checkPin];
}

// Background から復帰するときの処理
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    //[self checkPin];
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
