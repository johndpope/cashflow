//
//  AdIconViewParams.h
//  imobileAds
//
//  Copyright 2011 i-mobile Co.Ltd. All rights reserved.
//
//

// アイコン表示パラメータに従って広告を表示します
@interface ImobileSdkAdsIconParams : NSObject

// アイコン表示個数(初期値 : 4)
@property (atomic) NSInteger iconNumber;

// アイコン広告画像表示パラメータ
// アイコン広告表示レイアウトサイズ(初期値 : 画面の最大幅)
@property (atomic) NSInteger iconViewLayoutWidth;
// アイコン広告画像表示サイズ(初期値 : 57)
@property (atomic) NSInteger iconSize;


// アイコン広告タイトル表示パラメータ
// アイコン広告タイトル表示有無(初期値 : YES)
@property (atomic) BOOL iconTitleEnable;
// アイコン広告タイトルフォントサイズ(初期値 : 10)
@property (atomic) NSInteger iconTitleFontSize;
// アイコン広告タイトル表示e色(初期値 : 白[#FFFFFF])
@property (nonatomic, copy) NSString *iconTitleFontColor;
// アイコン広告タイトル表示位置設定(初期値 : 4)
@property (atomic) NSInteger iconTitleOffset;


// アイコン広告タイトル影表示パラメータ
// アイコン広告タイトル影の有無(初期値 : YES)
@property (atomic) BOOL iconTitleShadowEnable;
// アイコン広告タイトル影の色(初期値 : 黒[#000000])
@property (nonatomic, copy) NSString *iconTitleShadowColor;
// アイコン広告タイトル影の位置X(初期値 : 1)
@property (atomic) NSInteger iconTitleShadowDx;
// アイコン広告タイトル影の位置Y(初期値 : 1)
@property (atomic) NSInteger iconTitleShadowDy;

@end
