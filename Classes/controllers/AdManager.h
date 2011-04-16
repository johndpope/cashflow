// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import "GADBannerView.h"

#define ADMOB_PUBLISHER_ID  @"a14a8b599ca8e92"  // CashFlow Free

#define ADMOB_KEYWORDS @"マネー,預金,キャッシュ,クレジット,小遣い,貯金,資産+管理,money,deposit,cash,credit,allowance,spending+money,pocket+money,savings,saving+money,asset+management"

@class AdManager;

@protocol AdManagerDelegate
- (void)adManager:(AdManager*)adManager setAd:(UIView *)adView adSize:(CGSize)adSize;
- (void)adManager:(AdManager*)adManager showAd:(UIView *)adView adSize:(CGSize)adSize;
- (void)adManager:(AdManager*)adManager hideAd:(UIView *)adView adSize:(CGSize)adSize;
@end

@interface AdManager : NSObject <ADBannerViewDelegate, GADBannerViewDelegate>
{
    id<AdManagerDelegate> mDelegate;
    
    // iAd
    ADBannerView *mIADBannerView;
    CGSize mIAdSize;
    BOOL mIsIAdDisplayed;
    
    // AdMob
    GADBannerView *mGADBannerView;
    CGSize mGAdSize;
    BOOL mIsGAdDisplayed;
    BOOL mIsGAdBannerLoaded;
}

@property(nonatomic,assign) id<AdManagerDelegate> delegate;

+ (AdManager *)sharedInstance;

- (void)attach:(id<AdManagerDelegate>)delegate rootViewController:(UIViewController *)rootViewController;
- (void)detach;
- (void)replaceAd;

//- (void)startLoadAd;
- (void)_loadIAd;
- (void)_loadAdMob;

@end
