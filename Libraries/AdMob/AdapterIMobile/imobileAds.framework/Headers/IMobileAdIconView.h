//
//  IMobileAdIconView.h
//  imobileAds
//
//  Copyright 2011 i-mobile Co.Ltd. All rights reserved.
//
//
#import "IMobileAdView.h"
#import "IMobileAdIconViewParams.h"

@interface IMobileAdIconView : IMobileAdView{
@private
    int iconNumber_;
    IMobileAdIconViewParams *params_;
    
}

@property (nonatomic,readonly) int iconNumber;
@property (assign) IMobileAdIconViewParams *params;


- (id)initWithFrame:(CGRect)frame publisherId:(int)pId mediaId:(int)mId spotId:(int)sId iconNumber:(int)iconNumber;
- (id)initWithFrame:(CGRect)frame publisherId:(int)pId mediaId:(int)mId spotId:(int)sId iconNumber:(int)iconNumber params:(IMobileAdIconViewParams *)params;
- (id)initWithFrame:(CGRect)frame publisherId:(int)pId mediaId:(int)mId spotId:(int)sId iconNumber:(int)iconNumber testMode:(BOOL)isTestMode;
- (id)initWithFrame:(CGRect)frame publisherId:(int)pId mediaId:(int)mId spotId:(int)sId iconNumber:(int)iconNumber params:(IMobileAdIconViewParams *)params testMode:(BOOL)isTestMode;


- (void)setWithPublisherId:(int)pId mediaId:(int)mId spotId:(int)sId iconNumber:(int)iconNumber;
- (void)setWithPublisherId:(int)pId mediaId:(int)mId spotId:(int)sId iconNumber:(int)iconNumber params:(IMobileAdIconViewParams *)params;
- (void)setWithPublisherId:(int)pId mediaId:(int)mId spotId:(int)sId iconNumber:(int)iconNumber testMode:(BOOL)isTestMode;
- (void)setWithPublisherId:(int)pId mediaId:(int)mId spotId:(int)sId iconNumber:(int)iconNumber params:(IMobileAdIconViewParams *)params testMode:(BOOL)isTestMode;

@end
