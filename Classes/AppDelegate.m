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
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"
#import "UIDevice+Hardware.h"
//#import "Crittercism.h"
//#import <BugSense-iOS/BugSenseController.h>
#import <Crashlytics/Crashlytics.h>

#import "DropboxSecret.h"
#import "Config.h"

@implementation AppDelegate
{
    UIApplication *_application;

    UINavigationController *_detailNavigationController;
    
    UIView *_privacyView;
}

//
// バージョン番号文字列を返す
//
+ (NSString *)appVersion
{
    NSString *version = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"];
    return version;
}

+ (BOOL)isFreeVersion
{
#if FREE_VERSION
    return YES;
#else
    return NO;
#endif
}

- (id)init {
    self = [super init];
    return self;
}

//
// 開始処理
//
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"application:didFinishLaunchingWithOptions");
    _application = application;

    // Crittercism or BugSense
#if FREE_VERSION
#define CRITTERCISM_API_KEY @"50cdc6bb86ef114132000002"
#define BUGSENSE_API_KEY @"70f8a5d3"
#else
#define CRITTERCISM_API_KEY @"50cdc6697e69a342c7000005"
#define BUGSENSE_API_KEY @"b64aaa9e"
#endif
    
    //[Crittercism enableWithAppID:CRITTERCISM_API_KEY];
    //[BugSenseController sharedControllerWithBugSenseAPIKey:BUGSENSE_API_KEY];

    // Crashlytics
    [Crashlytics startWithAPIKey:@"532ecad9ca165fccdfe2d04c731d6b7449375147"];


    // Dropbox config
    DBSession *dbSession =
        [[DBSession alloc] initWithAppKey:DROPBOX_APP_KEY appSecret:DROPBOX_APP_SECRET root:kDBRootDropbox];
    //dbSession.delegate = self;
    [DBSession setSharedSession:dbSession];
    
    [self setupGoogleAnalytics];

    // Configure and show the window
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    UINavigationController *assetListNavigationController =
        [[UIStoryboard storyboardWithName:@"AssetListView" bundle:nil] instantiateInitialViewController];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        // iPhone 版 : Window 生成
        self.navigationController = _detailNavigationController = assetListNavigationController;
        self.window.rootViewController = self.navigationController;
    } else {
        // iPad 版 : Window 生成
        UINavigationController *masterNavigationController = assetListNavigationController;
        AssetListViewController *assetListViewController = (id)masterNavigationController.topViewController;

        TransactionListViewController *transactionListViewController = [TransactionListViewController instantiate];
        _detailNavigationController = [[UINavigationController alloc] initWithRootViewController:transactionListViewController];
    	
        assetListViewController.splitTransactionListViewController = transactionListViewController;
        transactionListViewController.splitAssetListViewController = assetListViewController;
    	
        self.splitViewController = [UISplitViewController new];
        self.splitViewController.delegate = transactionListViewController;
        self.splitViewController.viewControllers = @[masterNavigationController, _detailNavigationController];
        
        self.window.rootViewController = self.splitViewController;
    }
    [self.window makeKeyAndVisible];
    
    // PIN チェック
    [self checkPin];
    
    // 乱数初期化
    srand([[NSDate date] timeIntervalSinceReferenceDate]);
    
    // 遅延実行
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(delayedLaunchProcess:) userInfo:nil repeats:NO];
    
    NSLog(@"application:didFinishLaunchingWithOptions: done");
    return YES;
}

// Google Analytics 設定
- (void)setupGoogleAnalytics
{
    // Google analytics
    GAI *gai = [GAI sharedInstance];

    gai.trackUncaughtExceptions = YES;

    // デバッグログ
    //[gai.logger setLogLevel:kGAILogLevelVerbose];
    
    id<GAITracker> tracker = [gai trackerWithTrackingId:@"UA-413697-25"];
    
#if FREE_VERSION
    [tracker set:[GAIFields customDimensionForIndex:1] value:@"ios-free"];
#else
    [tracker set:[GAIFields customDimensionForIndex:1] value:@"ios-std"];
#endif
    
    // set custom dimensions
    NSString *version = [AppDelegate appVersion];
    [tracker set:[GAIFields customDimensionForIndex:2] value:version];
    
    UIDevice *dev = [UIDevice currentDevice];
    //NSString *model = [dev model];
    NSString *platform = [dev platform];
    NSString *systemVersion = [dev systemVersion];
    
    [tracker set:[GAIFields customDimensionForIndex:3] value:systemVersion];
    [tracker set:[GAIFields customDimensionForIndex:4] value:platform];
}

// プライバシービュー関連処理
- (UIView *)privacyView
{
    if (_privacyView == nil) {
        _privacyView = [[UIView alloc] initWithFrame:self.window.frame];
        _privacyView.backgroundColor = [UIColor whiteColor];
    }
    return _privacyView;
}

- (void)showPrivacyView
{
    [self.window addSubview:[self privacyView]];
}

- (void)hidePrivacyView
{
    [[self privacyView] removeFromSuperview];
}

// 起動時の遅延実行処理
- (void)delayedLaunchProcess:(NSTimer *)timer
{
    NSLog(@"delayedLaunchProcess");
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Application"
                                                          action:@"Launch"
                                                           label:nil
                                                           value:nil] build]];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"willResignActive" object:nil];
}

// Background に入る前の処理
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Background に入るまえに PIN コード表示を行っておく
    // 復帰時だと、前の画面が一瞬表示されたあとで PIN 画面がでてしまうので遅い
    [self checkPin];

    if ([PinController sharedController].pin != nil) {
        // snapshot 保存しない (うまく動作しないようだが、一応)
        [[UIApplication sharedApplication] ignoreSnapshotOnNextApplicationLaunch];

        // 画面を隠しておく
        //self.window.hidden = YES;
        [self showPrivacyView];
    }
}

// Background から復帰するときの処理
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"willEnterForeground" object:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // 画面表示
    //self.window.hidden = NO;
    [self hidePrivacyView];
}

- (void)checkPin
{
    PinController *pinController = [PinController sharedController];
    if (pinController != nil) {
        if (IS_IPAD) {
            [pinController firstPinCheck:self.splitViewController];
        } else {
            [pinController firstPinCheck:self.navigationController];
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

#pragma mark GoogleAnalytics
/*
+ (void)trackPageview:(NSString *)url
{
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker sendView:url];
}
 */

+ (void)trackEvent:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSInteger)value
{
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    
    NSNumber *n = @(value);
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:category
                                                          action:action
                                                           label:label
                                                           value:n] build]];
}

#pragma mark Debug

void AssertFailed(const char *filename, int lineno)
{
    UIAlertView *v = [[UIAlertView alloc]
                         initWithTitle:@"Assertion Failed"
                         message:[NSString stringWithFormat:@"%@ line %d", 
                                  @(filename) , lineno]
                         delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
    [v show];
}

@end
