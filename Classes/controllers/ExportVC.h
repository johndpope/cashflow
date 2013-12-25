// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

#import "ExportCsv.h"
#import "ExportOfx.h"

@interface ExportVC : UIViewController

@property(nonatomic,unsafe_unretained) Asset *asset;

+ (UINavigationController *)instantiate:(Asset *)aAsset;
- (IBAction)doExport;

@end
