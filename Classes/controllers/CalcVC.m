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

@interface CalculatorViewController()
- (IBAction)onButtonDown:(id)sender;
- (IBAction)onButtonPressed:(id)sender;

- (void)doneAction;
- (void)updateLabel;
- (void)allClear;
- (void)onInputOperator:(calcOperator)op;
- (void)onInputNumeric:(int)num;
- (void)roundInputValue;
@end

@implementation CalculatorViewController
{
    IBOutlet UILabel *numLabel;
    IBOutlet UIButton *button_Clear;
    IBOutlet UIButton *button_BS;
    IBOutlet UIButton *button_inv;
    IBOutlet UIButton *button_Period;
    IBOutlet UIButton *button_0;
    IBOutlet UIButton *button_1;
    IBOutlet UIButton *button_2;
    IBOutlet UIButton *button_3;
    IBOutlet UIButton *button_4;
    IBOutlet UIButton *button_5;
    IBOutlet UIButton *button_6;
    IBOutlet UIButton *button_7;
    IBOutlet UIButton *button_8;
    IBOutlet UIButton *button_9;
    
    IBOutlet UIButton *button_Plus;
    IBOutlet UIButton *button_Minus;
    IBOutlet UIButton *button_Multiply;
    IBOutlet UIButton *button_Divide;
    IBOutlet UIButton *button_Equal;

    id<CalculatorViewDelegate> __unsafe_unretained _delegate;
    double _value;

    calcState _state;
    int _decimalPlace; // 現在入力中の小数位

    NSNumberFormatter *_numberFormatter;

    double _storedValue;
    calcOperator _storedOperator;
}

+ (CalculatorViewController *)instantiate
{
    return [[UIStoryboard storyboardWithName:@"CalculatorView" bundle:nil] instantiateInitialViewController];
}

// Storyboard では init ではなく initWithCoder が呼ばれる
- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self allClear];
        _numberFormatter = [NSNumberFormatter new];
        [_numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [_numberFormatter setLocale:[NSLocale currentLocale]];
    }
    return self;
}

- (int)iosVersion
{
    NSArray  *aOsVersions = [[[UIDevice currentDevice]systemVersion] componentsSeparatedByString:@"."];
    NSInteger iOsVersionMajor  = [[aOsVersions objectAtIndex:0] intValue];
    return iOsVersionMajor;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // iOS6 以前には Helvetica Neue Thin がない
    if ([self iosVersion] < 7) {
        UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:68.0];
        [numLabel setFont:font];
    }
    
    //[AppDelegate trackPageview:@"/CalcViewController"];
    
    // 4inch 用 hack : 数字表示領域を上にずらす。
    // 本当は AutoLayout を使いたいが、iOS5 では AutoLayout が使えない
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    if (screenSize.height == 568.0) {
        CGRect frame = numLabel.frame;
        frame.origin.y -= 40.0;
        numLabel.frame = frame;
    }
    
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
    [_delegate calculatorViewChanged:self];

    if (!IS_IPAD && [self.navigationController.viewControllers count] == 1) {
        // I am modal view!
        [self dismissViewControllerAnimated:YES completion:NULL];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)allClear
{
    _value = 0.0;
    _state = ST_DISPLAY;
    _decimalPlace = 0;
    _storedOperator = OP_NONE;
    _storedValue = 0.0;
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
        if (_state == ST_INPUT) {
            if (_decimalPlace > 0) {
                _decimalPlace--;
                [self roundInputValue]; // TBD
            } else {
                _value = floor(_value / 10);
            }

            [self updateLabel];
        }
        return;
    }

    if (sender == button_inv) {
        _value = -_value;
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
    if (_state == ST_INPUT || op == OP_EQUAL) {
        // 数値入力中に演算ボタンが押された場合、
        // あるいは = が押された場合 (5x= など)
        // メモリしてある式を計算する
        switch (_storedOperator) {
            case OP_PLUS:
                _value = _storedValue + _value;
                break;

            case OP_MINUS:
                _value = _storedValue - _value;
                break;

            case OP_MULTIPLY:
                _value = _storedValue * _value;
                break;

            case OP_DIVIDE:
                if (_value == 0.0) {
                    // divided by zero error
                    _value = 0.0;
                } else {
                    _value = _storedValue / _value;
                }
                break;
                
            default:
                // ignore
                break;
        }

        // 表示中の値を記憶
        _storedValue = _value;

        // 表示状態に遷移
        _state = ST_DISPLAY;
        [self updateLabel];
    }
        
    // 表示中の場合は、operator を変えるだけ

    if (op == OP_EQUAL) {
        // '=' を押したら演算終了
        _storedOperator = OP_NONE;
    } else {
        _storedOperator = op;
    }
}

- (void)onInputNumeric:(int)num
{
    if (_state == ST_DISPLAY) {
        _state = ST_INPUT; // 入力状態に遷移

        _storedValue = _value;

        _value = 0; // 表示中の値をリセット
        _decimalPlace = 0;
    }

    if (num == -1) { // 小数点
        if (_decimalPlace == 0) {
            _decimalPlace = 1;
        }
    }
    else { // 数値
        if (_decimalPlace == 0) {
            // 整数入力
            _value = _value * 10 + num;
        } else {
            // 小数入力
            double v = (double)num * pow(10, -_decimalPlace);
            _value += v;

            _decimalPlace++;
        }
    }
         
    [self updateLabel];
}

- (void)roundInputValue
{
    double v;
    BOOL isMinus = NO;

    v = _value;
    if (v < 0.0) {
        isMinus = YES;
        v = -v;
    }

    _value = floor(v);
    v -= _value; // 小数点以下

    if (_decimalPlace >= 2) {
        // decimalPlace 桁以下を落とす
        double k = pow(10, _decimalPlace - 1);
        v = floor(v * k) / (double)k;
        _value += v;
    }

    if (isMinus) {
        _value = -_value;
    }
}

- (void)updateLabel
{
    // 表示すべき小数点以下の桁数を求める
    int dp = 0;
    double vtmp;

    switch (_state) {
    case ST_INPUT:
        dp = _decimalPlace - 1;
        break;

    case ST_DISPLAY:
        dp = -1;
        vtmp = _value;
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
    [_numberFormatter setMinimumFractionDigits:dp];
    [_numberFormatter setMaximumFractionDigits:dp];

    NSString *numstr = [_numberFormatter stringFromNumber:@(_value)];
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
