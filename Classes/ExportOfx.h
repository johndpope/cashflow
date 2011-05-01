// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

#import "ExportBase.h"
#import "Transaction.h"
#import "ExportServer.h"
#import "Asset.h"

@interface ExportOfx : ExportBase <UIAlertViewDelegate> {
    NSDateFormatter *mDateFormatter;
    NSCalendar *mGregCalendar;
}

// private
- (void)_statementTransactionResponse:(NSMutableString *)data asset:(Asset *)asset;
- (NSString*)_typeStringWithAssetEntry:(AssetEntry*)e;
- (NSString*)_dateStr:(NSDate*)date;
- (NSString*)_dateStrWithAssetEntry:(AssetEntry*)e;
- (NSString*)_fitIdWithAssetEntry:(AssetEntry*)e;
- (NSString*)_escapeXmlString:(NSString *)s;
@end
