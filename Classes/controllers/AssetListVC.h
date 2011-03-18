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

//#import "AdCell.h"

@interface AssetListViewController : UIViewController
<DataModelDelegate, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UIAlertViewDelegate>
{
    IBOutlet UITableView *mTableView;
    IBOutlet UIBarButtonItem *mBarActionButton;
    IBOutlet UIBarButtonItem *mBarSumLabel;

    BOOL mIsLoadDone;
    DBLoadingView *mLoadingView;
    
    Ledger *mLedger;

    NSArray *mIconArray;

    BOOL mAsDisplaying;
    UIActionSheet *mAsActionButton;
    UIActionSheet *mAsDelete;

    Asset *mAssetToBeDelete;
    
    BOOL mPinChecked;
    
    // for iPad (Split View)
    IBOutlet TransactionListViewController *mSplitTransactionListViewController;
}

@property(nonatomic,retain) UITableView *tableView;

- (void)_dataModelLoadedOnMainThread:(id)dummy;
- (void)_showInitialAsset;

- (void)reload;

- (int)_assetIndex:(NSIndexPath*)indexPath;

- (void)addAsset;

- (void)_actionDelete:(NSInteger)buttonIndex;

- (IBAction)showReport:(id)sender;
- (IBAction)doAction:(id)sender;
- (void)_actionActionButton:(NSInteger)buttonIndex;

@end
