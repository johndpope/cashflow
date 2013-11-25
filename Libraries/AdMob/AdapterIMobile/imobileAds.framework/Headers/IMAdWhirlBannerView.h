//
//  IMAdWhirlBannerView.h
//  imobileAds
//
//  Copyright 2011 i-mobile Co.Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMAdView.h"

@protocol IMobileAdDelegate;

@interface IMAdWhirlBannerView : IMobileAdView {
}

// AdWhirlを使用される場合、以下のメソッドを使用してインスタンスを生成してください。
+ (id)imAdWhirlBannerViewWithFrame:(CGRect)frame withDelegate:(id<IMobileAdDelegate>)delegate;
+ (id)imAdWhirlBannerViewWithFrame:(CGRect)frame withDelegate:(id<IMobileAdDelegate>)delegate testMode:(BOOL)isTestMode;

- (void)setDelegate:(id <IMobileAdDelegate>)theDelegate;

- (void)start;

@end
