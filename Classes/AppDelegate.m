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
//#import "CrashReportSender.h"
#import "GANTracker.h"
#import "UIDevice+Hardware.h"
#import "Crittercism.h"

#import "DropboxSecret.h"

@interface AppDelegate()
- (void)setupGoogleAnalytics;
- (void)delayedLaunchProcess:(NSTimer *)timer;
@end

@implementation AppDelegate
{
    UIApplication *_application;
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
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"application:didFinishLaunchingWithOptions");
    _application = application;

    // Crittercism
#if FREE_VERSION
    [Crittercism enableWithAppID:@"50cdc6bb86ef114132000002"];
#else
    [Crittercism enableWithAppID:@"50cdc6697e69a342c7000005"];
#endif
    
    // Dropbox config
    DBSession *dbSession =
        [[DBSession alloc] initWithAppKey:DROPBOX_APP_KEY appSecret:DROPBOX_APP_SECRET root:kDBRootDropbox];
    //dbSession.delegate = self;
    [DBSession setSharedSession:dbSession];
    
    [self setupGoogleAnalytics];

    // Configure and show the window
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        // iPhone 版 : Window 生成
        AssetListViewController *assetListViewController = [[AssetListViewController alloc] initWithNibName:@"AssetListView" bundle:nil];
        self.navigationController = [[UINavigationController alloc] initWithRootViewController:assetListViewController];
        self.window.rootViewController = self.navigationController;
    } else {
        // iPad 版 : Window 生成
        AssetListViewController *assetListViewController = [[AssetListViewController alloc] initWithNibName:@"AssetListView" bundle:nil];
        UINavigationController *masterNavigationController = [[UINavigationController alloc] initWithRootViewController:assetListViewController];
        
        TransactionListViewController *transactionListViewController = [[TransactionListViewController alloc] initWithNibName:@"TransactionListView" bundle:nil];
        UINavigationController *detailNavigationController = [[UINavigationController alloc] initWithRootViewController:transactionListViewController];
    	
        assetListViewController.splitTransactionListViewController = transactionListViewController;
        transactionListViewController.splitAssetListViewController = assetListViewController;
    	
        self.splitViewController = [[UISplitViewController alloc] init];
        self.splitViewController.delegate = transactionListViewController;
        self.splitViewController.viewControllers = @[masterNavigationController, detailNavigationController];
        
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
    GANTracker *tracker = [GANTracker sharedTracker];
    NSString *ua;
#if FREE_VERSION
    ua = @"UA-413697-22";
#else
    ua = @"UA-413697-23";
#endif
    [tracker startTrackerWithAccountID:ua dispatchPeriod:120 delegate:nil];
    
    // set custom variables
    NSString *version = [AppDelegate appVersion];
    [tracker setCustomVariableAtIndex:1 name:@"appVersion" value:version withError:nil];
    
    UIDevice *dev = [UIDevice currentDevice];
    //NSString *model = [dev model];
    NSString *platform = [dev platform];
    NSString *systemVersion = [dev systemVersion];
    //NSString *systemDesc = [NSString stringWithFormat:@"%@ %@", [dev model], [dev systemVersion]];
    [tracker setCustomVariableAtIndex:2 name:@"platform" value:platform withError:nil];
    [tracker setCustomVariableAtIndex:3 name:@"systemVersion" value:systemVersion withError:nil];
}

// 起動時の遅延実行処理
- (void)delayedLaunchProcess:(NSTimer *)timer
{
    NSLog(@"delayedLaunchProcess");
    
    GANTracker *tracker = [GANTracker sharedTracker];
    [tracker trackPageview:@"/applicationLaunched" withError:nil];    
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
                                  @(filename) , lineno]
                         delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
    [v show];
}

@end
