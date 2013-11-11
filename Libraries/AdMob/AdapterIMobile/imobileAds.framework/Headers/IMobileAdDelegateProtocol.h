//
//  IMobileAdDelegateProtocol.h
//  imobileAds
//
//  Copyright 2011 i-mobile Co.Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IMobileAdView;

@protocol IMobileAdDelegate <NSObject>

#pragma mark notifications
- (void)imAdViewDidFinishReceiveAd:(IMobileAdView *)imobileAdView;
- (void)imAdViewDidFailToReceiveAd:(IMobileAdView *)imobileAdView;
- (void)imAdViewDidClick:(IMobileAdView *)imobileAdView;

@end
