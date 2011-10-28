// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Transaction.h"

@class TransactionViewController;
@class CalculatorViewController;

@protocol CalculatorViewDelegate
- (void)calculatorViewChanged:(CalculatorViewController *)vc;
@end

typedef enum {
    OP_NONE = 0,
    OP_EQUAL,
    OP_PLUS,
    OP_MINUS,
    OP_MULTIPLY,
    OP_DIVIDE
} calcOperator;

typedef enum {
    ST_DISPLAY,
    ST_INPUT,
} calcState;

@interface CalculatorViewController : UIViewController {
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

    id<CalculatorViewDelegate> __unsafe_unretained mDelegate;
    double mValue;

    calcState mState;
    int mDecimalPlace; // 現在入力中の小数位

    NSNumberFormatter *mNumberFormatter;

    double mStoredValue;
    calcOperator mStoredOperator;
}

@property(nonatomic,assign) id<CalculatorViewDelegate> delegate;
@property(nonatomic,assign) double value;

- (IBAction)onButtonDown:(id)sender;
- (IBAction)onButtonPressed:(id)sender;

// private method
- (void)doneAction;
- (void)updateLabel;
- (void)allClear;
- (void)onInputOperator:(calcOperator)op;
- (void)onInputNumeric:(int)num;
- (void)roundInputValue;

@end
