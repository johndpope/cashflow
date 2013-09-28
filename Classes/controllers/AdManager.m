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
    id<AdManagerDelegate> __unsafe_unretained _delegate;
    
    BOOL _isShowAdSucceeded;
    
    // AdMob
    AdMobView *_adMobView;
    CGSize _adMobSize;
    BOOL _isAdMobShowing;
    BOOL _isAdMobBannerLoaded;
}
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
            _isShowAdSucceeded = NO;
        } else {
            _isShowAdSucceeded = YES;

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
    return _isShowAdSucceeded;
}

- (void)setIsShowAdSucceeded:(BOOL)value
{
    _isShowAdSucceeded = value;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:(value ? 1 : 0) forKey:@"ShowAds"];
    [defaults synchronize];
}

/**
 * 広告を ViewController に attach する
 */
- (void)attach:(id<AdManagerDelegate>)delegate rootViewController:(UIViewController *)rootViewController
{
    _delegate = delegate;
    _isAdMobShowing = NO;

    if (_adMobView != nil) {
        _adMobView.rootViewController = rootViewController;
        [_delegate adManager:self setAd:_adMobView adSize:_adMobSize];
    }
}

- (void)detach
{
    _delegate = nil;
    _adMobView.rootViewController = nil; // TODO これ大丈夫？

    [_adMobView removeFromSuperview];
}

/**
 * 広告を表示する
 */
- (void)showAd
{
    if (_delegate == nil) return;
    
    if (_adMobView != nil) {
        // AdMob が表示済みの場合は何もしない
        if (_isAdMobShowing) {
            NSLog(@"showAd: AdMob already showing");
            return;
        }

        // AdMob がロード済みの場合はこれを表示させる
        else if (_isAdMobBannerLoaded) {
            NSLog(@"showAd: show AdMob");
            [_delegate adManager:self showAd:_adMobView adSize:_adMobSize];
            _isAdMobShowing = YES;
        }
    
        // AdMob のリクエストを開始する
        else {
            NSLog(@"showAd: start load AdMob");
            GADRequest *req = [GADRequest request];
            if (AD_IS_TEST) {
                req.testing = YES;
            }
            [_adMobView loadRequest:req];
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
    _adMobSize = GAD_SIZE_320x50;
    
    /* Note: Mediation では標準サイズバナーのみ
    if (IS_IPAD) {
        gadSize = kGADAdSizeFullBanner;
        mAdMobSize = GAD_SIZE_468x60;
    }
    */

    _adMobView = [[AdMobView alloc] initWithAdSize:gadSize];
    _adMobView.delegate = self;
    
    _adMobView.adUnitID = ADMOB_MEDIATION_ID;
    _adMobView.rootViewController = nil; // この時点では不明
    _adMobView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;

    // まだリクエストは発行しない
}

/**
 * AdMob 解放
 */
- (void)_releaseAdMob
{
    NSLog(@"release AdMob");
    _isAdMobBannerLoaded = NO;

    if (_adMobView != nil) {
        _adMobView.delegate = nil;
        _adMobView.rootViewController = nil;
        _adMobView = nil;
    }
}

#pragma mark - AdMob : AdMobViewDelegate

- (void)adViewDidReceiveAd:(AdMobView *)view
{
    NSLog(@"AdMob loaded");
    _isAdMobBannerLoaded = YES;
    
    if (_delegate != nil && !_isAdMobShowing) {
        _isAdMobShowing = YES;
        [_delegate adManager:self showAd:_adMobView adSize:_adMobSize];
    }

    self.isShowAdSucceeded = YES;
}

- (void)adView:(AdMobView *)view didFailToReceiveAdWithError:(GADRequestError *)error
{
    NSString *msg;
    
    if (_adMobView.hasAutoRefreshed) {
        // auto refresh failed, but previous ad is effective.    
        msg = @"AdMob auto refresh failed";
    } else {
        msg = @"AdMob initial load failed";
    }
    NSLog(@"%@ : %@", msg, [error localizedDescription]);
}

@end
