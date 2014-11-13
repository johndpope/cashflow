// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import <XCTest/XCTest.h>
#import "TestCommon.h"

/**
   UIViewController 用の TestCase

   createViewController をオーバライドして使用すること
*/
@interface ViewControllerTestCase : XCTestCase
{
    UIViewController *mViewController;
    UIViewController *mBaseViewController;
}

@property(retain) UIViewController *viewController;
@property(retain) UIViewController *baseViewController;

- (UIViewController *)createViewController; // you must override this!
- (NSString *)viewControllerName;
- (NSString *)viewControllerNibName;

- (UIViewController *)createBaseViewController;

@end

/**
   UINavigationController 付き UIViewController の TestCase
*/
@interface ViewControllerWithNavBarTestCase : ViewControllerTestCase
{
}
@end
