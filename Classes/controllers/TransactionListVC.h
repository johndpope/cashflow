// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import "TransactionVC.h"
#import "ExportVC.h"
#import "DataModel.h"
#import "CalcVC.h"
#import "BackupVC.h"

#if FREE_VERSION
#import <iAd/iAd.h>
#import "GADBannerView.h"
#import "AdManager.h"
#endif

@class AssetListViewController;

@interface TransactionListViewController : UIViewController 
    <UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate, CalculatorViewDelegate, UISplitViewControllerDelegate, BackupViewDelegate
#if FREE_VERSION
    , AdManagerDelegate
#endif
>
{
    IBOutlet UITableView *mTableView;
    IBOutlet UIBarButtonItem *mBarBalanceLabel;
    IBOutlet UIBarButtonItem *mBarActionButton;
    IBOutlet UIToolbar *mToolbar;
	
    int mAssetKey;
    //Asset *mAssetCache;
    
#if FREE_VERSION
    AdManager *mAdManager;
#endif
    
    BOOL mAsDisplaying;
    
    // for Split view
    IBOutlet AssetListViewController *mSplitAssetListViewController;
    UIPopoverController *mPopoverController;
}

//- (UITableView*)tableView;
@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,assign) int assetKey;
@property(nonatomic,readonly) Asset *asset;
@property(nonatomic,strong) UIPopoverController *popoverController;

- (int)entryIndexWithIndexPath:(NSIndexPath *)indexPath;
- (AssetEntry *)entryWithIndexPath:(NSIndexPath *)indexPath;
- (void)reload;
- (void)updateBalance;
- (void)addTransaction;

- (IBAction)showReport:(id)sender;
- (IBAction)doAction:(id)sender;
//- (IBAction)showHelp:(id)sender;

@end
