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
#endif

@class AssetListViewController;

@interface TransactionListViewController : UIViewController 
    <UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate, CalculatorViewDelegate, UISplitViewControllerDelegate, BackupViewDelegate
#if FREE_VERSION
    , ADBannerViewDelegate, GADBannerViewDelegate
#endif
>
{
    IBOutlet UITableView *mTableView;
    IBOutlet UIBarButtonItem *mBarBalanceLabel;
    IBOutlet UIBarButtonItem *mBarActionButton;
    IBOutlet UIToolbar *mToolbar;
	
    int mAssetKey;
    Asset *mAssetCache;
    
#if FREE_VERSION
    ADBannerView *mADBannerView;
    GADBannerView *mGADBannerView;
    BOOL mIsAdDisplayed;
    CGSize mAdSize;
#endif
    
    BOOL mAsDisplaying;
    
    // for Split view
    IBOutlet AssetListViewController *mSplitAssetListViewController;
    UIPopoverController *mPopoverController;
}

//- (UITableView*)tableView;
@property(nonatomic,retain) UITableView *tableView;
@property(nonatomic,assign) int assetKey;
@property(nonatomic,readonly) Asset *asset;
@property(nonatomic,retain) UIPopoverController *popoverController;

- (int)entryIndexWithIndexPath:(NSIndexPath *)indexPath;
- (AssetEntry *)entryWithIndexPath:(NSIndexPath *)indexPath;
- (void)reload;
- (void)updateBalance;
- (void)addTransaction;

- (IBAction)showReport:(id)sender;
- (IBAction)doAction:(id)sender;
//- (IBAction)showHelp:(id)sender;

#if FREE_VERSION
- (void)_startLoadAd;
- (void)_loadIAd;
- (void)_loadAdMob;
- (void)_showAd:(UIView *)adView;
- (void)_hideAd:(UIView *)adView;
#endif

@end
