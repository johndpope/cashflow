//
//  IMobileAdView.h
//  imobileAds
//
//  Copyright 2011 i-mobile Co.Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// スマートフォンバナー 320x50
#define kIMAdViewDefaultWidth 320
#define kIMAdViewDefaultHeight 50
#define kIMAdViewDefaultFrame (CGRectMake(0, 0, kIMAdViewDefaultWidth, kIMAdViewDefaultHeight))

// バナー 468x60
#define kIMAdViewBannerWidth 468
#define kIMAdViewBannerHeight 60
#define kIMAdViewBannerFrame (CGRectMake(0, 0, kIMAdViewBannerWidth, kIMAdViewBannerHeight))

// ビッグバナー 728x90
#define kIMAdViewBigBannerWidth 728
#define kIMAdViewBigBannerHeight 90
#define kIMAdViewBigBannerFrame (CGRectMake(0, 0, kIMAdViewBigBannerWidth, kIMAdViewBigBannerHeight))

// スカイスクレイパー 120x600
#define kIMAdViewSkyscraperWidth 120
#define kIMAdViewSkyscraperHeight 600
#define kIMAdViewSkyscraperFrame (CGRectMake(0, 0, kIMAdViewSkyscraperWidth, kIMAdViewSkyscraperHeight))

// ワイドスカイスクレイパー 160x600
#define kIMAdViewWideSkyscraperWidth 160
#define kIMAdViewWideSkyscraperHeight 600
#define kIMAdViewWideSkyscraperFrame (CGRectMake(0, 0, kIMAdViewWideSkyscraperWidth, kIMAdViewWideSkyscraperHeight))

// スクエア(小) 200x200
#define kIMAdViewSquareSmallWidth 200
#define kIMAdViewSquareSmallHeight 200
#define kIMAdViewSquareSmallFrame (CGRectMake(0, 0, kIMAdViewSquareSmallWidth, kIMAdViewSquareSmallHeight))

// スクエア 250x250
#define kIMAdViewSquareWidth 250
#define kIMAdViewSquareHeight 250
#define kIMAdViewSquareFrame (CGRectMake(0, 0, kIMAdViewSquareWidth, kIMAdViewSquareHeight))

// レクタングル(中) 300x250
#define kIMAdViewRectangleMiddleWidth 300
#define kIMAdViewRectangleMiddleHeight 250
#define kIMAdViewRectangleMiddleFrame (CGRectMake(0, 0, kIMAdViewRectangleMiddleWidth, kIMAdViewRectangleMiddleHeight))

// レクタングル(大) 336x280
#define kIMAdViewRectangleBigWidth 336
#define kIMAdViewRectangleBigHeight 280
#define kIMAdViewRectangleBigFrame (CGRectMake(0, 0, kIMAdViewRectangleBigWidth, kIMAdViewRectangleBigHeight))

@interface IMobileAdView : UIView {
@protected
    int publisherId_;
    int mediaId_;
    int spotId_;
}

@property (nonatomic,readonly) int publisherId;
@property (nonatomic,readonly) int mediaId;
@property (nonatomic,readonly) int spotId;

- (id)initWithFrame:(CGRect)frame publisherId:(int)pId mediaId:(int)mId spotId:(int)sId;
- (id)initWithFrame:(CGRect)frame publisherId:(int)pId mediaId:(int)mId spotId:(int)sId testMode:(BOOL)isTestMode;

- (void)setWithPublisherId:(int)pId mediaId:(int)mId spotId:(int)sId;
- (void)setWithPublisherId:(int)pId mediaId:(int)mId spotId:(int)sId testMode:(BOOL)isTestMode;

@end
