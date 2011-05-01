// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "AdManager.h"
#import "AppDelegate.h"

#define AD_IS_TEST  YES

@implementation AdMobView
- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.delegate = self;
    }
    return self;
}

- (void)dealloc {
    self.delegate = nil;
    [super dealloc];
}
@end


#pragma mark - AdManager implementation

@implementation AdManager

static AdManager *theAdManager;

+ (AdManager *)sharedInstance
{
    if (theAdManager == nil) {
        theAdManager = [AdManager new];
    }
    return theAdManager;
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        // 前回広告ロードが成功したかどうかを取得
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        int n = [defaults integerForKey:@"ShowAds"];
        if (n == 0) {
            mIsShowAdSucceeded = NO;
        } else {
            mIsShowAdSucceeded = YES;

            // プロパティ上は NO にセットしておく(途中クラッシュ対処)
            [defaults setInteger:0 forKey:@"ShowAds"];
            [defaults synchronize];
        }

        [self _createIAd];
        [self _createAdMob];
    }
    return self;
}

- (void)dealloc {
    [self _releaseIAd];
    [self _releaseAdMob];
    
    [super dealloc];
}

- (BOOL)isShowAdSucceeded
{
    return mIsShowAdSucceeded;
}

- (void)setIsShowAdSucceeded:(BOOL)value
{
    mIsShowAdSucceeded = value;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:(value ? 1 : 0) forKey:@"ShowAds"];
    [defaults synchronize];
}

- (void)attach:(id<AdManagerDelegate>)delegate rootViewController:(UIViewController *)rootViewController
{
    mDelegate = delegate;
    mIsIAdShowing = NO;
    mIsAdMobShowing = NO;

    if (mIADBannerView != nil) {
        if ([mIADBannerView isBannerLoaded]) {
            /* iAd がロードされている場合、AdMob はここで解放し、以降 refresh がかからないようにする */
            [self _releaseAdMob];
        }
    
        [mDelegate adManager:self setAd:mIADBannerView adSize:mIAdSize];
    }

    if (mAdMobView != nil) {
        mAdMobView.rootViewController = rootViewController;
        [mDelegate adManager:self setAd:mAdMobView adSize:mAdMobSize];
    }
}

- (void)detach
{
    mDelegate = nil;
    mAdMobView.rootViewController = nil; // TODO これ大丈夫？
}

/**
 * 広告を表示する
 */
- (void)showAd
{
    if (mDelegate == nil) return;
    
    // iAd がすでに表示されている場合は何もしない
    if (mIsIAdShowing) {
        NSLog(@"showAd: iAd already showing");
        return;
    }
    
    // iAd がロード済みの場合は、iAd を表示する
    if (mIADBannerView != nil && [mIADBannerView isBannerLoaded]) {
        if (mIsAdMobShowing) {
            // AdMob が表示されている場合は hide する
            NSLog(@"showAd: hide AdMob");
            mIsAdMobShowing = NO;
            [mDelegate adManager:self hideAd:mAdMobView adSize:mAdMobSize];
        }

        NSLog(@"showAd: show iAd");
        [mDelegate adManager:self showAd:mIADBannerView adSize:mIAdSize];
        mIsIAdShowing = YES;
    }
    
    else if (mAdMobView != nil) {
        // AdMob が表示済みの場合は何もしない
        if (mIsAdMobShowing) {
            NSLog(@"showAd: AdMob already showing");
            return;
        }

        // AdMob がロード済みの場合はこれを表示させる
        else if (mIsAdMobBannerLoaded) {
            NSLog(@"showAd: show AdMob");
            [mDelegate adManager:self showAd:mAdMobView adSize:mAdMobSize];
            mIsAdMobShowing = YES;
        }
    
        // AdMob のリクエストを開始する
        else {
            NSLog(@"showAd: start load AdMob");
            GADRequest *req = [GADRequest request];
            if (AD_IS_TEST) {
                req.testing = YES;
            }
            [mAdMobView loadRequest:req];
        }
    } else {
        NSLog(@"showAd: no ad to show");
    }
}

#pragma mark - Internal

/**
 * iAd 表示開始
 */
- (void)_createIAd
{
    float systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (systemVersion >= 4.0) {
        NSLog(@"create iAd");
        if (IS_IPAD) {
            mIAdSize = CGSizeMake(766, 66);
        } else {
            mIAdSize = CGSizeMake(320, 50);
        }
    
        mIADBannerView = [[ADBannerView alloc] initWithFrame:CGRectZero];
        if (systemVersion >= 4.2) {
            // ADBannerContentSizeIdentifierPortait は iOS 4.2 以降でしか使えない
            mIADBannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
        } else {
            mIADBannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifier320x50;
        }
        mIADBannerView.delegate = self;
        mIADBannerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    }
}

/**
 * iAd 解放
 */
- (void)_releaseIAd
{
    NSLog(@"release iAd");
    if (mIADBannerView != nil) {
        mIADBannerView.delegate = nil;
        [mIADBannerView release];
        mIADBannerView = nil;
    }
}

/**
 * AdMob 表示開始
 */
- (void)_createAdMob
{
    NSLog(@"create AdMob");
    
    if (IS_IPAD) {
        mAdMobSize = GAD_SIZE_468x60;
        //mAdSize = GAD_SIZE_728x90;
    } else {
        mAdMobSize = GAD_SIZE_320x50;
    }
    
    CGRect frame = CGRectMake(0, 0, mAdMobSize.width, mAdMobSize.height);
    mAdMobView = [[AdMobView alloc] initWithFrame:frame];
    mAdMobView.delegate = self;
    
    mAdMobView.adUnitID = ADMOB_PUBLISHER_ID;
    mAdMobView.rootViewController = nil; // この時点では不明
    mAdMobView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;

    // まだリクエストは発行しない
}

/**
 * AdMob 解放
 */
- (void)_releaseAdMob
{
    NSLog(@"release AdMob");
    mIsAdMobBannerLoaded = NO;

    if (mAdMobView != nil) {
        mAdMobView.delegate = nil;
        mAdMobView.rootViewController = nil;
        [mAdMobView release];
        mAdMobView = nil;
    }
}

#pragma mark - iAd : ADBannerViewDelegate

/** iAd表示成功 */
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    NSLog(@"iAd loaded");
    
    if (mDelegate != nil && !mIsAdMobShowing && !mIsIAdShowing) {
        mIsIAdShowing = YES;
        [mDelegate adManager:self showAd:mIADBannerView adSize:mIAdSize];
        self.isShowAdSucceeded = YES;
    }
}

/** iAd取得失敗 */
- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    if ([mIADBannerView isBannerLoaded]) {
        NSLog(@"iAd auto refresh failed");
        return; // do not hide ad
    }

    NSLog(@"iAd load failed");
    if (mIsIAdShowing) {
        NSLog(@"hide iAd"); // 広告リロードの場合でも、isBannerLoaded = NO の場合がある。
        mIsIAdShowing = NO;
        [mDelegate adManager:self hideAd:mIADBannerView adSize:mIAdSize];
        
        // try to show AdMob
        [self showAd];
    }
}

#pragma mark - AdMob : AdMobViewDelegate

- (void)adViewDidReceiveAd:(AdMobView *)view
{
    NSLog(@"AdMob loaded");
    mIsAdMobBannerLoaded = YES;
    
    if (mDelegate != nil && !mIsAdMobShowing && !mIsIAdShowing) {
        mIsAdMobShowing = YES;
        [mDelegate adManager:self showAd:mAdMobView adSize:mAdMobSize];
    }

    self.isShowAdSucceeded = YES;
}

- (void)adView:(AdMobView *)view didFailToReceiveAdWithError:(GADRequestError *)error
{
    if (mAdMobView.hasAutoRefreshed) {
        // auto refresh failed, but previous ad is effective.    
        NSLog(@"AdMob auto refresh failed");
    } else {
        NSLog(@"AdMob initial load failed");
    }
}

@end
