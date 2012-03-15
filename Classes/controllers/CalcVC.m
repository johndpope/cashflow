// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <AudioToolbox/AudioToolbox.h>
#import <math.h>

#import "TransactionVC.h"
#import "CalcVC.h"
#import "AppDelegate.h"

// private method
@interface CalculatorViewController()
- (void)doneAction;
- (void)updateLabel;
- (void)allClear;
- (void)onInputOperator:(calcOperator)op;
- (void)onInputNumeric:(int)num;
- (void)roundInputValue;
@end

@implementation CalculatorViewController

@synthesize delegate = mDelegate;
@synthesize value = mValue;

- (id)init
{
    self = [super initWithNibName:@"CalculatorView" bundle:nil];
    if (self) {
        [self allClear];
        mNumberFormatter = [[NSNumberFormatter alloc] init];
        [mNumberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [mNumberFormatter setLocale:[NSLocale currentLocale]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //[AppDelegate trackPageview:@"/CalcViewController"];
    
    if (IS_IPAD) {
        CGSize s = self.contentSizeForViewInPopover;
        s.height = 480;
        self.contentSizeForViewInPopover = s;
    }
    self.title = _L(@"Amount"); // 金額
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                  initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                  target:self
                                                  action:@selector(doneAction)];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self updateLabel];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void)doneAction
{
    [mDelegate calculatorViewChanged:self];

    if (!IS_IPAD && [self.navigationController.viewControllers count] == 1) {
        // I am modal view!
        [self dismissModalViewControllerAnimated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)allClear
{
    mValue = 0.0;
    mState = ST_DISPLAY;
    mDecimalPlace = 0;
    mStoredOperator = OP_NONE;
    mStoredValue = 0.0;
}

- (IBAction)onButtonDown:(id)sender
{
    // play keyboard click sound
    AudioServicesPlaySystemSound(1105);
}

- (IBAction)onButtonPressed:(id)sender
{
    if (sender == button_Clear) {
        [self allClear];
        [self updateLabel];
        return;
    }

    if (sender == button_BS) {
        // バックスペース
        if (mState == ST_INPUT) {
            if (mDecimalPlace > 0) {
                mDecimalPlace--;
                [self roundInputValue]; // TBD
            } else {
                mValue = floor(mValue / 10);
            }

            [self updateLabel];
        }
        return;
    }

    if (sender == button_inv) {
        mValue = -mValue;
        [self updateLabel];
        return;
    }

    // 演算子入力
    calcOperator op = OP_NONE;
    if (sender == button_Plus) op = OP_PLUS;
    else if (sender == button_Minus) op = OP_MINUS;
    else if (sender == button_Multiply) op = OP_MULTIPLY;
    else if (sender == button_Divide) op = OP_DIVIDE;
    else if (sender == button_Equal) op = OP_EQUAL;

    if (op != OP_NONE) {
        [self onInputOperator:op];
        return;
    }
		
    // 数値入力
    int num = -99;
    if (sender == button_0) num = 0;
    else if (sender == button_1) num = 1;
    else if (sender == button_2) num = 2;
    else if (sender == button_3) num = 3;
    else if (sender == button_4) num = 4;
    else if (sender == button_5) num = 5;
    else if (sender == button_6) num = 6;
    else if (sender == button_7) num = 7;
    else if (sender == button_8) num = 8;
    else if (sender == button_9) num = 9;
    else if (sender == button_Period) num = -1;
    
    if (num != -99) {
        [self onInputNumeric:num];
    }
}

- (void)onInputOperator:(calcOperator)op
{
    if (mState == ST_INPUT || op == OP_EQUAL) {
        // 数値入力中に演算ボタンが押された場合、
        // あるいは = が押された場合 (5x= など)
        // メモリしてある式を計算する
        switch (mStoredOperator) {
            case OP_PLUS:
                mValue = mStoredValue + mValue;
                break;

            case OP_MINUS:
                mValue = mStoredValue - mValue;
                break;

            case OP_MULTIPLY:
                mValue = mStoredValue * mValue;
                break;

            case OP_DIVIDE:
                if (mValue == 0.0) {
                    // divided by zero error
                    mValue = 0.0;
                } else {
                    mValue = mStoredValue / mValue;
                }
                break;
                
            default:
                // ignore
                break;
        }

        // 表示中の値を記憶
        mStoredValue = mValue;

        // 表示状態に遷移
        mState = ST_DISPLAY;
        [self updateLabel];
    }
        
    // 表示中の場合は、operator を変えるだけ

    if (op == OP_EQUAL) {
        // '=' を押したら演算終了
        mStoredOperator = OP_NONE;
    } else {
        mStoredOperator = op;
    }
}

- (void)onInputNumeric:(int)num
{
    if (mState == ST_DISPLAY) {
        mState = ST_INPUT; // 入力状態に遷移

        mStoredValue = mValue;

        mValue = 0; // 表示中の値をリセット
        mDecimalPlace = 0;
    }

    if (num == -1) { // 小数点
        if (mDecimalPlace == 0) {
            mDecimalPlace = 1;
        }
    }
    else { // 数値
        if (mDecimalPlace == 0) {
            // 整数入力
            mValue = mValue * 10 + num;
        } else {
            // 小数入力
            double v = (double)num * pow(10, -mDecimalPlace);
            mValue += v;

            mDecimalPlace++;
        }
    }
         
    [self updateLabel];
}

- (void)roundInputValue
{
    double v;
    BOOL isMinus = NO;

    v = mValue;
    if (v < 0.0) {
        isMinus = YES;
        v = -v;
    }

    mValue = floor(v);
    v -= mValue; // 小数点以下

    if (mDecimalPlace >= 2) {
        // decimalPlace 桁以下を落とす
        double k = pow(10, mDecimalPlace - 1);
        v = floor(v * k) / (double)k;
        mValue += v;
    }

    if (isMinus) {
        mValue = -mValue;
    }
}

- (void)updateLabel
{
    // 表示すべき小数点以下の桁数を求める
    int dp = 0;
    double vtmp;

    switch (mState) {
    case ST_INPUT:
        dp = mDecimalPlace - 1;
        break;

    case ST_DISPLAY:
        dp = -1;
        vtmp = mValue;
        if (vtmp < 0) vtmp = -vtmp;
        vtmp -= (int)vtmp;
        for (int i = 1; i <= 6; i++) {
            vtmp *= 10;
            if ((int)vtmp % 10 != 0) {
                dp = i;
            }
        }
        break;
    }

#if 1
    if (dp < 0) dp = 0;
    [mNumberFormatter setMinimumFractionDigits:dp];
    [mNumberFormatter setMaximumFractionDigits:dp];

    NSString *numstr = [mNumberFormatter stringFromNumber:[NSNumber numberWithDouble:mValue]];
    numLabel.text = numstr;

#else
    NSMutableString *numstr = [[NSMutableString alloc] initWithCapacity:16];

    if (dp <= 0) {
        [numstr appendFormat:@"%.0f", mValue];
    } else {
        NSString *fmt = [NSString stringWithFormat:@"%%.%df", dp];
        [numstr appendFormat:fmt, mValue];
    }

    // カンマを３桁ごとに挿入
    NSRange range = [numstr rangeOfString:@"."];
    int i;
    if (range.location == NSNotFound) {
        i = numstr.length;
    } else {
        i = range.location;
    }

    for (i -= 3 ; i > 0; i -= 3) {
        if (mValue < 0 && i <= 1) break;
        [numstr insertString:@"," atIndex:i];
    }
	
    numLabel.text = numstr;
    [numstr release];
#endif
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (IS_IPAD) return YES;
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
@end
