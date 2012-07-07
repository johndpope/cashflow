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

@interface CalculatorViewController : UIViewController

@property(nonatomic,unsafe_unretained) id<CalculatorViewDelegate> delegate;
@property(nonatomic,assign) double value;

@end
