// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import <UIKit/UIKit.h>
#import "TestCommon.h"

@implementation ViewControllerTestCase

@synthesize viewController = mViewController;
@synthesize baseViewController = mBaseViewController;

- (void)setUp
{
    [super setUp];

    self.viewController = [self createViewController];
    self.baseViewController = [self createBaseViewController];

    UIWindow *window = [UIApplication sharedApplication].keyWindow;

    [window addSubview:mBaseViewController.view];
    [window bringSubviewToFront:mBaseViewController.view];
}

- (void)tearDown
{
    [self.baseViewController.view removeFromSuperview];
    self.baseViewController = nil;
    self.viewController = nil;

    [super tearDown];
}    

- (UIViewController *)createViewController
{
    NSString *nibName = [self viewControllerNibName];
    NSString *className = [self viewControllerName];
    if (nibName && className == nil) {
        className = nibName;
    }
    if (className == nil) {
        XCTFail(@"You must override viewControllerName/viewControllerNibName or createViewController!");
        return nil;
    }
    
    Class class = NSClassFromString(className);
    if (nibName) {
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        return [[class alloc] initWithNibName:nibName bundle:bundle];
    } else {
        return [class new];
    }
}

- (NSString *)viewControllerName
{
    return nil;
}

- (NSString *)viewControllerNibName
{
    return nil;
}

- (UIViewController *)createBaseViewController
{
    return self.viewController;
}

@end

////////////////////////////////////////////////////////////////////

@implementation ViewControllerWithNavBarTestCase

- (UIViewController *)createBaseViewController
{
    UINavigationController *vc = [[UINavigationController alloc] initWithRootViewController:self.viewController];
    return vc;
}
    
@end
