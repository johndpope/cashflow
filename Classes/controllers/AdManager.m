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
 * 2) 広告ロード前 (_isAdMobShowing, _isAdLoaded ともに false)
 * 3) 広告ロード済み、未表示 (_isAdLoaded が true)
 * 4) 広告表示中 (_isAdShowing が true)
 */
@interface AdManager()
{
    __weak id<AdManagerDelegate> _delegate;
    __weak UIViewController *_rootViewController;
    
    // 広告ビュー
    AdMobView *_bannerView;
    
    // 広告サイズ
    CGSize _adSize;

    // 広告ロード済み状態
    BOOL _isAdLoaded;

    // 広告表示中状態
    BOOL _isAdShowing;

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
    return self;
}

- (void)dealloc {
    // singleton なのでここには原則こない
    [self _releaseAdView];
    [self detach];
}

/**
 * 広告を ViewController に attach する
 */
- (void)attach:(id<AdManagerDelegate>)delegate rootViewController:(UIViewController *)rootViewController
{
    _delegate = delegate;
    _rootViewController = rootViewController;
    _isAdShowing = NO;
}

- (void)detach
{
    _delegate = nil;
    _rootViewController = nil;
    
    // 広告を root view から抜く
    if (_bannerView != nil) {
        _bannerView.rootViewController = nil; // TODO これ大丈夫？
        [_bannerView removeFromSuperview];
    }
    _isAdShowing = NO;

    // view controller からデタッチされた場合、
    // 次回は必ずリロードする
    _lastAdRequestDate = nil;
}

/**
 * 広告を表示を要求する
 */
- (void)requestShowAd
{
    if (_delegate == nil) return; // デタッチ状態

    if (_bannerView == nil) {
        [self _createAdView];
        _bannerView.rootViewController = _rootViewController;
    }
    
    BOOL forceRequest = NO;
    
    if (!_isAdShowing) {
        // 広告未表示の場合
        if (_isAdLoaded) {
            // ロード済みの場合、表示する
            NSLog(@"showAd: show loaded ad");
            [_delegate adManager:self showAd:_bannerView adSize:_adSize];
            _isAdShowing = YES;
        } else {
            // ロード済みでない場合は、すぐに広告リクエストを発行する
            forceRequest = YES;
        }
    }
    
    [self _requestAd:forceRequest];
}

/**
 * 広告リクエストを発行する
 */
- (void)_requestAd:(BOOL)forceRequest
{
    // 一定時間経過していない場合、リクエストは発行しない
    if (!forceRequest) {
        if (_lastAdRequestDate != nil) {
            NSDate *now = [NSDate date];
            float diff = [now timeIntervalSinceDate:_lastAdRequestDate];
            if (diff < AD_REQUEST_INTERVAL) {
                NSLog(@"requestAd: do not request ad (within ad interval)");
                return;
            }
        }
    }
    
    // 広告リクエストを開始する
    NSLog(@"requestAd: start request new ad.");
    GADRequest *req = [GADRequest request];
    if (AD_IS_TEST) {
        req.testing = YES;
    }
    [_bannerView loadRequest:req];

    // リクエスト時刻を保存
    _lastAdRequestDate = [NSDate date];
}

#pragma mark - Internal

/**
 * 広告作成
 */
- (void)_createAdView
{
    NSLog(@"create Ad view");
    
    //GADAdSize gadSize = kGADAdSizeBanner;
    _adSize = GAD_SIZE_320x50;
    CGRect gadSize = CGRectMake(0.0, 0.0, 320.0, 50.0);
    
    /* Note: Mediation では標準サイズバナーのみ
    if (IS_IPAD) {
        gadSize = kGADAdSizeFullBanner;
        mAdMobSize = GAD_SIZE_468x60;
    }
    */

    AdMobView *view = [[AdMobView alloc] initWithFrame:gadSize];
    view.delegate = self;
    
    NSLog(@"AdUnit = %@", ADUNIT_ID);
    view.adUnitID = ADUNIT_ID;
    view.rootViewController = nil; // この時点では不明
    view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;

    // まだリクエストは発行しない

    _bannerView = view;
}

/**
 * 広告解放
 */
- (void)_releaseAdView
{
    NSLog(@"release Ad view");
    _isAdLoaded = NO;

    if (_bannerView != nil) {
        _bannerView.delegate = nil;
        _bannerView.rootViewController = nil;
        _bannerView = nil;
    }
}

#pragma mark - GADBannerViewDelegate

- (void)adViewDidReceiveAd:(GADBannerView *)view
{
    NSLog(@"Ad loaded");
    _isAdLoaded = YES;
    
    if (_delegate != nil && !_isAdShowing) {
        _isAdShowing = YES;
        [_delegate adManager:self showAd:_bannerView adSize:_adSize];
    }
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error
{
    NSString *msg;

    if (_bannerView == nil) return;
    
    if (_bannerView.hasAutoRefreshed) {
        // auto refresh failed, but previous ad is effective.    
        msg = @"Ad auto refresh failed";
    } else {
        msg = @"Ad load failed";
    }
    NSLog(@"%@ : %@", msg, [error localizedDescription]);
    
    _isAdLoaded = NO;

    // workaround for AdMob bugs.
    [_delegate adManager:self removeAd:_bannerView adSize:_adSize];
    _isAdShowing = NO;

    [self _releaseAdView];

    _lastAdRequestDate = nil;
}

@end
