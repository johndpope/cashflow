// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "AdManager.h"
#import "AppDelegate.h"

#define AD_IS_TEST  NO

@implementation AdMobView

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.delegate = self;
    }
    return self;
}

- (void)dealloc {
    self.delegate = nil;
}
@end


#pragma mark - AdManager implementation

@interface AdManager()
{
    id<AdManagerDelegate> __unsafe_unretained mDelegate;
    
    BOOL mIsShowAdSucceeded;
    
    // AdMob
    AdMobView *mAdMobView;
    CGSize mAdMobSize;
    BOOL mIsAdMobShowing;
    BOOL mIsAdMobBannerLoaded;
}

- (void)_createAdMob;
- (void)_releaseAdMob;
@end

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

        [self _createAdMob];
    }
    return self;
}

- (void)dealloc {
    [self _releaseAdMob];
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

/**
 * 広告を ViewController に attach する
 */
- (void)attach:(id<AdManagerDelegate>)delegate rootViewController:(UIViewController *)rootViewController
{
    mDelegate = delegate;
    mIsAdMobShowing = NO;

    if (mAdMobView != nil) {
        mAdMobView.rootViewController = rootViewController;
        [mDelegate adManager:self setAd:mAdMobView adSize:mAdMobSize];
    }
}

- (void)detach
{
    mDelegate = nil;
    mAdMobView.rootViewController = nil; // TODO これ大丈夫？

    [mAdMobView removeFromSuperview];
}

/**
 * 広告を表示する
 */
- (void)showAd
{
    if (mDelegate == nil) return;
    
    if (mAdMobView != nil) {
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
 * AdMob 表示開始
 */
- (void)_createAdMob
{
    NSLog(@"create AdMob");
    
    GADAdSize gadSize = kGADAdSizeBanner;
    mAdMobSize = GAD_SIZE_320x50;
    
    /* Note: Mediation では標準サイズバナーのみ
    if (IS_IPAD) {
        gadSize = kGADAdSizeFullBanner;
        mAdMobSize = GAD_SIZE_468x60;
    }
    */

    mAdMobView = [[AdMobView alloc] initWithAdSize:gadSize];
    mAdMobView.delegate = self;
    
    mAdMobView.adUnitID = ADMOB_MEDIATION_ID;
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
        mAdMobView = nil;
    }
}

#pragma mark - AdMob : AdMobViewDelegate

- (void)adViewDidReceiveAd:(AdMobView *)view
{
    NSLog(@"AdMob loaded");
    mIsAdMobBannerLoaded = YES;
    
    if (mDelegate != nil && !mIsAdMobShowing) {
        mIsAdMobShowing = YES;
        [mDelegate adManager:self showAd:mAdMobView adSize:mAdMobSize];
    }

    self.isShowAdSucceeded = YES;
}

- (void)adView:(AdMobView *)view didFailToReceiveAdWithError:(GADRequestError *)error
{
    NSString *msg;
    
    if (mAdMobView.hasAutoRefreshed) {
        // auto refresh failed, but previous ad is effective.    
        msg = @"AdMob auto refresh failed";
    } else {
        msg = @"AdMob initial load failed";
    }
    NSLog(@"%@ : %@", msg, [error localizedDescription]);
}

@end
