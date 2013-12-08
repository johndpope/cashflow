// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import "GADBannerView.h"
#import "DFPBannerView.h"

#define DFP_ADUNIT_ID @"/86480491/CashFlowFree_iOS_320x50"

//#define ADMOB_PUBLISHER_ID  @"a14a8b599ca8e92"  // CashFlow Free
//#define ADMOB_MEDIATION_ID @"ee06b031bb1847d4";

//#define ADMOB_KEYWORDS @"マネー,預金,キャッシュ,クレジット,小遣い,貯金,資産+管理,money,deposit,cash,credit,allowance,spending+money,pocket+money,savings,saving+money,asset+management"

// AdMob wrapper (to avoid crash)
//@interface AdMobView : GADBannerView <GADBannerViewDelegate>
@interface AdMobView : DFPBannerView <GADBannerViewDelegate>
@end

@class AdManager;

//
// AdManager からの通知用インタフェース
//
@protocol AdManagerDelegate
- (void)adManager:(AdManager*)adManager setAd:(UIView *)adView adSize:(CGSize)adSize;
- (void)adManager:(AdManager*)adManager showAd:(UIView *)adView adSize:(CGSize)adSize;
- (void)adManager:(AdManager*)adManager hideAd:(UIView *)adView adSize:(CGSize)adSize;
@end

//
// AdManager : 広告表示用マネージャ
//
@interface AdManager : NSObject <GADBannerViewDelegate>

@property(nonatomic,assign) BOOL isShowAdSucceeded;

+ (AdManager *)sharedInstance;

- (void)attach:(id<AdManagerDelegate>)delegate rootViewController:(UIViewController *)rootViewController;
- (void)detach;
- (void)showAd;

@end
