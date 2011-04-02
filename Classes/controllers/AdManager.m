// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "AdManager.h"
#import "AppDelegate.h"

@implementation AdManager

@synthesize adSize = mAdSize;

- (id)init:(id<AdManagerDelegate>)delegate rootViewController:(UIViewController *)rootViewController
{
    self = [super init];
    if (self) {
        mDelegate = delegate;
        mRootViewController = rootViewController;
    }
    return self;
}

- (void)dealloc {
    [mADBannerView release];
    [mGADBannerView release];
    [super dealloc];
}

/**
 * 広告表示開始
 */
- (void)startLoadAd
{
    if (mADBannerView == nil && mGADBannerView == nil) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0) {
            [self _loadIAd];
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
}

/** iAd表示成功 */
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    NSLog(@"iAd loaded");
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
    
    mGADBannerView = [[GADBannerView alloc] init];
    mGADBannerView.delegate = self;
    
    mGADBannerView.adUnitID = ADMOB_PUBLISHER_ID;
    mGADBannerView.rootViewController = mRootViewController;
    mGADBannerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    mIsAdDisplayed = NO;
    
    GADRequest *req = [GADRequest request];
    //req.testing = YES;
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
    // do nothing...
}

@end
