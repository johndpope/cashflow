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

@interface ExportVC : UIViewController {
    IBOutlet UIButton *mExportButton;
    IBOutlet UISegmentedControl *mFormatControl;
    IBOutlet UISegmentedControl *mRangeControl;
    IBOutlet UISegmentedControl *mMethodControl;
    IBOutlet UILabel *mFormatLabel;
    IBOutlet UILabel *mRangeLabel;
    IBOutlet UILabel *mMethodLabel;

    ExportCsv *mCsv;
    ExportOfx *mOfx;

    Asset *__unsafe_unretained mAsset;
}

@property(nonatomic,assign) Asset *asset;

- (IBAction)doExport;
- (id)initWithAsset:(Asset *)asset;
- (void)doneAction:(id)sender;

@end
