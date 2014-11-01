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

#import <iAd/iAd.h>
#import "GADBannerView.h"
#import "AdManager.h"

@class AssetListViewController;

@interface TransactionListViewController : UIViewController 
    <UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate, CalculatorViewDelegate, UISplitViewControllerDelegate, BackupViewDelegate, UIPopoverControllerDelegate,
        UISearchDisplayDelegate, UISearchBarDelegate, AdManagerDelegate
>

@property(nonatomic,strong) AssetListViewController *splitAssetListViewController;
@property(nonatomic,assign) NSInteger assetKey;

+ (TransactionListViewController *)instantiate;
- (void)reload;

@end
