// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "AdManager.h"
#import "AppDelegate.h"

// 広告テスト時に YES
#define AD_IS_TEST  NO

// 広告リクエスト間隔 (画面遷移時のみ)
#define AD_REQUEST_INTERVAL     45.0

/**
 *  AdMob 表示用ラッパクラス。GADBannerView を継承。
 */
@interface AdMobView : DFPBannerView <GADBannerViewDelegate>
@end

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


/**
 * 広告マネージャ
 *
 * Note: 広告の状態は以下のとおり
 * 1) View未アタッチ状態 (_bannerView == nil)
 * 2) 広告ロード前 (_isAdMobShowing, _isAdMobBannerLoaded ともに false)
 * 3) 広告ロード済み、未表示 (_isAdMobBannerLoaded が true)
 * 4) 広告表示中 (_isAdMobShowing が true)
 */
@interface AdManager()
{
    id<AdManagerDelegate> __unsafe_unretained _delegate;
    
    BOOL _isShowAdSucceeded;
    
    // AdMob
    AdMobView *_bannerView;
    
    CGSize _adMobSize;

    BOOL _isAdMobShowing;
    BOOL _isAdMobBannerLoaded;

    // 最後に広告をリクエストした日時
    NSDate *_lastAdRequestDate;
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

    if (_bannerView != nil) {
        _bannerView.rootViewController = rootViewController;
        [_delegate adManager:self setAd:_bannerView adSize:_adMobSize];
    }
}

- (void)detach
{
    _delegate = nil;
    _bannerView.rootViewController = nil; // TODO これ大丈夫？

    [_bannerView removeFromSuperview];
}

/**
 * 広告を表示する
 */
- (void)showAd
{
    if (_delegate == nil) return;

    if (_bannerView == nil) {
        NSLog(@"showAd: no ad to show");
        return;
    }
    
    BOOL doRequest = NO;
    
    if (!_isAdMobShowing) {
        // 広告未表示の場合
        if (_isAdMobBannerLoaded) {
            // ロード済みの場合、表示する
            NSLog(@"showAd: show AdMob");
            [_delegate adManager:self showAd:_bannerView adSize:_adMobSize];
            _isAdMobShowing = YES;
        } else {
            // ロード済みでない場合は、すぐに広告リクエストを発行する
            doRequest = YES;
        }
    }

    // 一定時間経過していない場合、リクエストは発行しない
    if (!doRequest) {
        if (_lastAdRequestDate != nil) {
            NSDate *now = [NSDate date];
            float diff = [now timeIntervalSinceDate:_lastAdRequestDate];
            if (diff < AD_REQUEST_INTERVAL) {
                NSLog(@"showAd: AdMob already showing");
                return;
            }
        }
    }
    
    // 広告リクエストを開始する
    NSLog(@"showAd: start load ad.");
    GADRequest *req = [GADRequest request];
    if (AD_IS_TEST) {
        req.testing = YES;
    }
    [_bannerView loadRequest:req];

    _lastAdRequestDate = [NSDate date];
}

#pragma mark - Internal

/**
 * AdMob 表示開始
 */
- (void)_createAdMob
{
    NSLog(@"create AdMob");
    
    //GADAdSize gadSize = kGADAdSizeBanner;
    _adMobSize = GAD_SIZE_320x50;
    CGRect gadSize = CGRectMake(0.0, 0.0, 320.0, 50.0);
    
    /* Note: Mediation では標準サイズバナーのみ
    if (IS_IPAD) {
        gadSize = kGADAdSizeFullBanner;
        mAdMobSize = GAD_SIZE_468x60;
    }
    */

    _bannerView = [[AdMobView alloc] initWithFrame:gadSize];
    _bannerView.delegate = self;
    
    //NSLog(@"AdUnit = %@", ADUNIT_ID);
    _bannerView.adUnitID = ADUNIT_ID;
    _bannerView.rootViewController = nil; // この時点では不明
    _bannerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;

    // まだリクエストは発行しない
}

/**
 * AdMob 解放
 */
- (void)_releaseAdMob
{
    NSLog(@"release AdMob");
    _isAdMobBannerLoaded = NO;

    if (_bannerView != nil) {
        _bannerView.delegate = nil;
        _bannerView.rootViewController = nil;
        _bannerView = nil;
    }
}

#pragma mark - AdMob : AdMobViewDelegate

- (void)adViewDidReceiveAd:(AdMobView *)view
{
    NSLog(@"AdMob loaded");
    _isAdMobBannerLoaded = YES;
    
    if (_delegate != nil && !_isAdMobShowing) {
        _isAdMobShowing = YES;
        [_delegate adManager:self showAd:_bannerView adSize:_adMobSize];
    }

    self.isShowAdSucceeded = YES;
}

- (void)adView:(AdMobView *)view didFailToReceiveAdWithError:(GADRequestError *)error
{
    NSString *msg;
    
    if (_bannerView.hasAutoRefreshed) {
        // auto refresh failed, but previous ad is effective.    
        msg = @"AdMob auto refresh failed";
    } else {
        msg = @"AdMob load failed";
    }
    NSLog(@"%@ : %@", msg, [error localizedDescription]);
}

@end
