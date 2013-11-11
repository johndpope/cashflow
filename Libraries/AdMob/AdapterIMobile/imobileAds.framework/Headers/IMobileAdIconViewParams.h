//
//  AdIconViewParams.h
//  imobileAds
//
//  Copyright 2011 i-mobile Co.Ltd. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface IMobileAdIconViewParams : NSObject{
@private
	
    //アイコン広告画像表示パラメータ
	//アイコン広告画像表示サイズ
	CGFloat iconSize_;

	//アイコン広告画像表示レイアウト
	//アイコン広告表示間隔
	CGFloat iconSpaceMargin_;
	//アイコン広告表示枠(左マージン)
	CGFloat iconMarginLeft_;
	//アイコン広告表示枠(右マージン)
	CGFloat iconMarginRight_;
	//アイコン広告画像表示間隔(上マージン)
	CGFloat iconMarginTop_;
	//アイコン広告画像表示間隔(下マージン)
	CGFloat iconMarginBottom_;
	//アイコン均等配置
	BOOL iconJustify_;
    
	//アイコン広告タイトル表示パラメータ
	//アイコン広告タイトル表示有無
	BOOL iconTitleEnable_;
	//アイコン広告タイトルレングスカット
	BOOL iconTitleLengthCut_;
	//アイコン広告タイトルフォントファイル名
	UIFont *iconTitleFont_;
	//アイコン広告タイトルフォントサイズ
	CGFloat iconTitleFontSize_;
	//アイコン広告タイトルフォントカラー
	UIColor *iconTitleFontColor_;
	//アイコン広告タイトル表示位置設定
	UITextAlignment iconTitleGravity_;
	//アイコン広告タイトル文字影付き 有無
	BOOL iconTitleShadowEnable_;
	//タイトル文字影付き 影の色
	UIColor *iconTitleShadowColor_;
	//タイトル文字影付き 影の位置 X
	float iconTitleShadowDx_;
	//タイトル文字影付き 影の位置 Y
	float iconTitleShadowDy_;
	//タイトル文字影付き 影のぼかし具合
    //	float iconTitleShadowRadus_;
}
@property (nonatomic, assign) CGFloat iconSize;
@property (nonatomic, assign) CGFloat iconSpaceMargin;
@property (nonatomic, assign) CGFloat iconMarginLeft;
@property (nonatomic, assign) CGFloat iconMarginRight;
@property (nonatomic, assign) CGFloat iconMarginTop;
@property (nonatomic, assign) CGFloat iconMarginBottom;
@property (nonatomic, assign) BOOL iconJustify;

@property (nonatomic, assign) BOOL iconTitleEnable;
@property (nonatomic, assign) BOOL iconTitleLengthCut;
@property (nonatomic, retain) NSString *iconTitleFont;
@property (nonatomic, retain) UIColor *iconTitleFontColor;
@property (nonatomic, assign) UITextAlignment iconTitleGravity;
@property (nonatomic, assign) CGFloat iconTitleFontSize;

@property (nonatomic, assign) BOOL iconTitleShadowEnable;
@property (nonatomic, retain) UIColor *iconTitleShadowColor;
@property (nonatomic, assign) float iconTitleShadowDx;
@property (nonatomic, assign) float iconTitleShadowDy;
//@property (nonatomic, assign) float iconTitleShadowRadus;


@end
