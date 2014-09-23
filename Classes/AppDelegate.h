// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>

#import "DataModel.h"
#import "AssetListVC.h"
#import "TransactionListVC.h"
#import "CurrencyManager.h"

#define DBNAME  @"CashFlow.db"

@interface AppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic,strong) UIWindow *window;
@property (nonatomic,strong) UINavigationController *navigationController;
@property (nonatomic,strong) UISplitViewController *splitViewController;

- (void)checkPin;
+ (NSString *)appVersion;

//+ (void)trackPageview:(NSString *)url;
+ (void)trackEvent:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSInteger)value;

// Utility
#define _L(msg)  NSLocalizedString(msg, @"")

void AssertFailed(const char *filename, int lineno);
#ifdef NDEBUG
#define ASSERT(x)  if (!(x)) AssertFailed(__FILE__, __LINE__)
#else
#define ASSERT(x) /**/
#endif

#ifndef UI_USER_INTERFACE_IDIOM
#define IS_IPAD NO
#else
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#endif

@end

