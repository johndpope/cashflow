// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <DropboxSDK/DropboxSDK.h>

#import "AppDelegate.h"
#import "TransactionListVC.h"
#import "DataModel.h"
#import "Transaction.h"
#import "PinController.h"
#import "CrashReportSender.h"
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

//
// バージョン番号文字列を返す
//
+ (NSString *)appVersion
{
    NSString *version = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"];
    return version;
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
        [[DBSession alloc] initWithAppKey:DROPBOX_APP_KEY appSecret:DROPBOX_APP_SECRET root:kDBRootDropbox];
    //dbSession.delegate = self;
    [DBSession setSharedSession:dbSession];
    
    // Google analytics
    GANTracker *tracker = [GANTracker sharedTracker];
    NSString *ua;
#if FREE_VERSION
    ua = @"UA-413697-22";
#else
    ua = @"UA-413697-23";
#endif
    [tracker startTrackerWithAccountID:ua dispatchPeriod:30 delegate:nil];
    
    // set custom variables
    NSString *version = [AppDelegate appVersion];
    [tracker setCustomVariableAtIndex:1 name:@"appVersion" value:version withError:nil];
    
    UIDevice *dev = [UIDevice currentDevice];
    NSString *model = [dev model];
    NSString *systemVersion = [dev systemVersion];
    //NSString *systemDesc = [NSString stringWithFormat:@"%@ %@", [dev model], [dev systemVersion]];
    [tracker setCustomVariableAtIndex:2 name:@"model" value:model withError:nil];
    [tracker setCustomVariableAtIndex:3 name:@"systemVersion" value:systemVersion withError:nil];
    
    [tracker trackPageview:@"/applicationDidFinishLaunching" withError:nil];

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

//
// Dropbox link 完了時の処理
//
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    UIAlertView *v;
    
    if ([[DBSession sharedSession] handleOpenURL:url]) {
        if ([[DBSession sharedSession] isLinked]) {
            NSLog(@"Dropbox linked successfully");
            v = [[UIAlertView alloc] initWithTitle:@"Dropbox" 
                                           message:@"Login successful, please retry backup or export." 
                                          delegate:nil 
                                 cancelButtonTitle:@"Close" 
                                 otherButtonTitles:nil];
            [v show];
        } else {
            // TODO:
        }
        return YES;
    }
    return NO;
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

#pragma mark GoogleAnalytics
+ (void)trackPageview:(NSString *)url
{
    NSError *err;
    
    GANTracker *tracker = [GANTracker sharedTracker];
    [tracker trackPageview:url withError:&err];
}

+ (void)trackEvent:(NSString *)category action:(NSString *)action label:(NSString *)label value:(int)value
{
    GANTracker *tracker = [GANTracker sharedTracker];
    [tracker trackEvent:category action:action label:label value:value withError:nil];
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
}

@end
