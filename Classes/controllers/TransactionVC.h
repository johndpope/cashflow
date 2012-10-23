// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Transaction.h"

#import "EditTypeVC.h"
#import "EditDescVC.h"
#import "CalcVC.h"
#import "EditDateVC.h"
#import "EditMemoVC.h"
#import "CategoryListVC.h"
#import "CalendarViewController.h"

@interface TransactionViewController : UIViewController 
    <UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,
    EditMemoViewDelegate, EditTypeViewDelegate,
    EditDateViewDelegate, CalculatorViewDelegate,
    EditDescViewDelegate, CategoryListViewDelegate,
    CalendarViewControllerDelegate,
    UIPopoverControllerDelegate>

@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,unsafe_unretained) Asset *asset;
@property(nonatomic,strong) AssetEntry *editingEntry;

- (void)setTransactionIndex:(int)n;
- (void)saveAction;
- (void)cancelAction;

@end
