// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import "DataModel.h"
#import "TransactionListVC.h"
#import "DBLoadingView.h"
#import "BackupVC.h"

//#import "AdCell.h"

@interface AssetListViewController : UIViewController
<DataModelDelegate, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UIAlertViewDelegate, BackupViewDelegate>
{
    IBOutlet UITableView *mTableView;
    IBOutlet UIBarButtonItem *mBarActionButton;
    IBOutlet UIBarButtonItem *mBarSumLabel;

    BOOL mIsLoadDone;
    DBLoadingView *mLoadingView;
    
    Ledger *mLedger;

    NSMutableArray *mIconArray;

    BOOL mAsDisplaying;
    UIActionSheet *mAsActionButton;
    UIActionSheet *mAsDelete;

    Asset *mAssetToBeDelete;
    
    BOOL mPinChecked;
    
    // for iPad (Split View)
    IBOutlet TransactionListViewController *mSplitTransactionListViewController;
}

@property(nonatomic,retain) UITableView *tableView;

- (void)reload;
- (void)addAsset;
- (IBAction)showReport:(id)sender;
- (IBAction)doAction:(id)sender;

@end
