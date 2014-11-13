// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import "TestCommon.h"
#import "AssetListVC.h"
#import "PinController.h"

@interface PinControllerTest : ViewControllerWithNavBarTestCase {
    PinController *mPinController;
}

// PinController は assetListViewController から呼び出されるため、必要
@property AssetListViewController *vc;

@end

@implementation PinControllerTest

- (UIViewController *)createViewController
{
    // AssetListView は storyboard から生成する
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"AssetListView" bundle:nil];

    // 最上位は navigation controller なので、ここから AssetListViewController を取り出す
    UINavigationController *nv = [sb instantiateInitialViewController];
    UIViewController *av = [nv topViewController];

    // 重要: loadView を実行する
    [av performSelectorOnMainThread:@selector(loadView) withObject:nil waitUntilDone:YES];
    return av;
}

- (AssetListViewController *)vc
{
    return self.viewController;
}

#pragma mark UIViewControllerTest methods

- (NSString *)viewControllerName
{
    return @"AssetListViewController";
}

- (NSString *)viewControllerNibName
{
    return @"AssetListView";
}

- (BOOL)hasNavigationController
{
    return YES;
}

#pragma mark -

- (void)setUp
{
    [super setUp];

    [PinController _deleteSingleton];
    mPinController = [PinController sharedController];

    //[self.vc viewDidLoad]; // ###
    //[self.vc viewWillAppear:YES]; // ###
}

- (void)tearDown
{
    //[vc viewWillDisappear:YES];
    [super tearDown];
}

- (void)testNoPin
{
    PinController *saved = mPinController;
    
    mPinController.pin = nil;
    [mPinController firstPinCheck:self.vc];
    // この時点で、Pin チェック完了したため、PinController の singleton は削除されているはず
    
    PinController *new = [PinController sharedController];
    XCTAssert(new != saved);
    
    // modal view がでていないことを確認する
    //AssertNil(self.vc.modalViewController);
    XCTAssertNil(self.vc.presentedViewController);
}

- (void)testHasPin
{
    PinController *saved = mPinController;
    
    mPinController.pin = @"1234";
    [mPinController firstPinCheck:self.vc];

    // Pin があるため、この時点ではまだ終了していないはず
    PinController *new = [PinController sharedController];
    XCTAssert(new == saved);
    
    // modal view が出ていることを確認する
    UINavigationController *nv = (UINavigationController *)self.vc.presentedViewController;
    XCTAssertNotNil(nv);
    PinViewController *vc = (PinViewController *)(nv.viewControllers)[0];
    XCTAssertNotNil(vc);
    
    /*
    [vc _onKeyIn:@"1"];
    [vc _onKeyIn:@"2"];
    [vc _onKeyIn:@"3"];
    [vc _onKeyIn:@"4"];
     */
}

@end
