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
    <UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate, CalculatorViewDelegate, UISplitViewControllerDelegate, BackupViewDelegate, UIPopoverControllerDelegate
#if FREE_VERSION
    , AdManagerDelegate
#endif
>

@property(nonatomic,strong) AssetListViewController *splitAssetListViewController;
@property(nonatomic,assign) int assetKey;

- (void)reload;

@end
