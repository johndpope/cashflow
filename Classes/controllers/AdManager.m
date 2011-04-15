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

@synthesize adSize = mAdSize;
@synthesize delegate = mDelegate;

static int sIAdSuccededCount = 0;

- (id)init:(id<AdManagerDelegate>)delegate rootViewController:(UIViewController *)rootViewController
{
    self = [super init];
    if (self) {
        self.delegate = delegate;
        mRootViewController = rootViewController;
    }
    return self;
}

- (void)dealloc {
    if (mADBannerView != nil) {
        mADBannerView.delegate = nil;
        [mADBannerView release];
    }
    if (mGADBannerView != nil) {
        mGADBannerView.delegate = nil;
        mGADBannerView.rootViewController = nil;
        [mGADBannerView release];
    }
    [super dealloc];
}

/**
 * 広告表示開始
 */
- (void)startLoadAd
{
    if (mADBannerView == nil && mGADBannerView == nil) {
        // iAd は iOS 4.0 以上のみ
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0) {
            // 過去 iAd のロードに1回でも成功していれば iAd を
            // そうでない場合は、一定確率で AdMob をロードする
            if (sIAdSuccededCount > 0 || (rand() % 100) < 50) {
                [self _loadIAd];
            } else {
                [self _loadAdMob];
            }
        } else {
            [self _loadAdMob];
        }
    }
}

/**
 * iAd 表示開始
 */
- (void)_loadIAd
{
    NSLog(@"start load iAd");
    
    if (IS_IPAD) {
        mAdSize = CGSizeMake(766, 66);
    } else {
        mAdSize = CGSizeMake(320, 50);
    }
    
    mADBannerView = [[ADBannerView alloc] init];
    mADBannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
    mADBannerView.delegate = self;
    mADBannerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    mIsAdDisplayed = NO;
    
    [mDelegate adManager:self setAd:mADBannerView];
}

/** iAd表示成功 */
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    NSLog(@"iAd loaded");
    
    sIAdSuccededCount++;
    
    if (!mIsAdDisplayed) {
        mIsAdDisplayed = YES;
        [mDelegate adManager:self showAd:mADBannerView];
    }
}

/** iAd取得失敗 */
- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"iAd load failed");
    
    if (mIsAdDisplayed) {
        mIsAdDisplayed = NO;
        [mDelegate adManager:self hideAd:mADBannerView];
    }
    [mDelegate adManager:self removeAd:mADBannerView];
    
    [mADBannerView release];
    mADBannerView = nil;
    
    [self _loadAdMob];
}

/**
 * AdMob 表示開始
 */
- (void)_loadAdMob
{
    NSLog(@"start load AdMob");
    
    if (IS_IPAD) {
        mAdSize = GAD_SIZE_468x60;
        //mAdSize = GAD_SIZE_728x90;
    } else {
        mAdSize = GAD_SIZE_320x50;
    }
    
    CGRect frame = CGRectMake(0, 0, mAdSize.width, mAdSize.height);
    mGADBannerView = [[GADBannerView alloc] initWithFrame:frame];
    mGADBannerView.delegate = self;
    
    mGADBannerView.adUnitID = ADMOB_PUBLISHER_ID;
    mGADBannerView.rootViewController = mRootViewController;
    mGADBannerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [mDelegate adManager:self setAd:mGADBannerView];
    
    mIsAdDisplayed = NO;
    
    GADRequest *req = [GADRequest request];
    if (AD_IS_TEST) {
        req.testing = YES;
    }
    [mGADBannerView loadRequest:req];
}

- (void)adViewDidReceiveAd:(GADBannerView *)view
{
    NSLog(@"AdMob loaded");
    if (!mIsAdDisplayed) {
        mIsAdDisplayed = YES;
        [mDelegate adManager:self showAd:mGADBannerView];
    }
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error
{
    NSLog(@"AdMob load failed");
    
    if (mIsAdDisplayed) {
        mIsAdDisplayed = NO;
        [mDelegate adManager:self hideAd:mGADBannerView];
    }
#if 0
    // iAd に切り替える場合の処理
    [mDelegate adManager:self removeAd:mGADBannerView];
    
    mGADBannerView.delegate = nil; // clear delegate to avoid crash!

    // delegate 内で release するとクラッシュする模様。autorelease で遅延させる。
    [mGADBannerView autorelease];
    mGADBannerView = nil;
    
    [self _loadIAd];
#endif
}

@end
