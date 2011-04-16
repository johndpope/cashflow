// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "AdManager.h"
#import "AppDelegate.h"

#define AD_IS_TEST  YES

@implementation AdManager

@synthesize delegate = mDelegate;

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
        [self _loadIAd];
        [self _loadAdMob];
    }
    return self;
}

- (void)dealloc {
    if (mIADBannerView != nil) {
        mIADBannerView.delegate = nil;
        [mIADBannerView release];
    }
    
    if (mGADBannerView != nil) {
        mGADBannerView.delegate = nil;
        mGADBannerView.rootViewController = nil;
        [mGADBannerView release];
    }
    
    [super dealloc];
}

- (void)attach:(id<AdManagerDelegate>)delegate rootViewController:(UIViewController *)rootViewController
{
    self.delegate = delegate;
    mIsIAdShowing = NO;
    mIsGAdShowing = NO;

    /*
       iAd がロードされている場合、AdMob はここで解放し、以降 refresh がかからないようにする
     */
    if (mIADBannerView != nil && [mIADBannerView isBannerLoaded] && mGADBannerView != nil) {
        mGADBannerView.delegate = nil;
        mGADBannerView.rootViewController = nil;
        [mGADBannerView release];
        mGADBannerView = nil;
        
        mIsGAdBannerLoaded = NO;
    }
    
    if (mIADBannerView != nil) {
        [mDelegate adManager:self setAd:mIADBannerView adSize:mIAdSize];
    }

    if (mGADBannerView != nil) {
        mGADBannerView.rootViewController = rootViewController;
        [mDelegate adManager:self setAd:mGADBannerView adSize:mGAdSize];
    }
}

/**
 * 広告を表示する
 */
- (void)showAd
{
    if (mDelegate == nil) return;
    
    // iAd がすでに表示されている場合は何もしない
    if (mIsIAdShowing) {
        return;
    }
    
    // iAd がロード済みの場合は、iAd に切り替える
    if (mIADBannerView != nil && [mIADBannerView isBannerLoaded]) {
        if (mIsGAdShowing) {
            // AdMob が表示されている場合は hide する
            mIsGAdShowing = NO;
            [mDelegate adManager:self hideAd:mGADBannerView adSize:mGAdSize];
        }
        
        [mDelegate adManager:self showAd:mIADBannerView adSize:mIAdSize];
        mIsIAdShowing = YES;
    }
    
    else if (mGADBannerView != nil) {
        // AdMob が表示済みの場合は何もしない
        if (mIsGAdShowing) {
            return;
        }

        // AdMob がロード済みの場合はこれを表示させる
        else if (mIsGAdBannerLoaded) {
            [mDelegate adManager:self showAd:mGADBannerView adSize:mGAdSize];
            mIsGAdShowing = YES;
        }
    
        // AdMob のリクエストを開始する
        else {
            GADRequest *req = [GADRequest request];
            if (AD_IS_TEST) {
                req.testing = YES;
            }
            [mGADBannerView loadRequest:req];
        }
    }
}

- (void)detach
{
    self.delegate = nil;
    
    mGADBannerView.rootViewController = nil; // TODO これ大丈夫？
}

#pragma mark - Internal

/**
 * iAd 表示開始
 */
- (void)_loadIAd
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0) {
        if (IS_IPAD) {
            mIAdSize = CGSizeMake(766, 66);
        } else {
            mIAdSize = CGSizeMake(320, 50);
        }
    
        mIADBannerView = [[ADBannerView alloc] init];
        mIADBannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
        mIADBannerView.delegate = self;
        mIADBannerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    }
}

/**
 * AdMob 表示開始
 */
- (void)_loadAdMob
{
    NSLog(@"start load AdMob");
    
    if (IS_IPAD) {
        mGAdSize = GAD_SIZE_468x60;
        //mAdSize = GAD_SIZE_728x90;
    } else {
        mGAdSize = GAD_SIZE_320x50;
    }
    
    CGRect frame = CGRectMake(0, 0, mGAdSize.width, mGAdSize.height);
    mGADBannerView = [[GADBannerView alloc] initWithFrame:frame];
    mGADBannerView.delegate = self;
    
    mGADBannerView.adUnitID = ADMOB_PUBLISHER_ID;
    mGADBannerView.rootViewController = nil; // この時点では不明
    mGADBannerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
}

#pragma mark - iAd : ADBannerViewDelegate

/** iAd表示成功 */
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    NSLog(@"iAd loaded");
    
    if (mDelegate != nil && !mIsGAdShowing && !mIsIAdShowing) {
        mIsIAdShowing = YES;
        [mDelegate adManager:self showAd:mIADBannerView adSize:mIAdSize];
    }
}

/** iAd取得失敗 */
- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"iAd load failed");
    
    if ([mIADBannerView isBannerLoaded]) {
        NSLog(@"but prev iAd is effective.");
        return;
    }

#if 0    
    if (mIsIAdShowing) {
        mIsIAdShowing = NO;
        [mDelegate adManager:self hideAd:mIADBannerView adSize:mIAdSize];
    }
#endif
}

#pragma mark - AdMob : GADBannerViewDelegate

- (void)adViewDidReceiveAd:(GADBannerView *)view
{
    NSLog(@"AdMob loaded");
    mIsGAdBannerLoaded = YES;
    
    if (mDelegate != nil && !mIsGAdShowing && !mIsIAdShowing) {
        mIsGAdShowing = YES;
        [mDelegate adManager:self showAd:mGADBannerView adSize:mGAdSize];
    }
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error
{
    if (mGADBannerView.hasAutoRefreshed) {
        // auto refresh failed, but previous ad is effective.    
        NSLog(@"AdMob auto refresh failed");
        return;
    }
    
    NSLog(@"AdMob load failed");
#if 0
    if (mIsGAdShowing) {
        mIsGAdShowing = NO;
        [mDelegate adManager:self hideAd:mGADBannerView adSize:mGAdSize];
    }
#endif
}

@end
