// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import "TestCommon.h"
#import "AssetListVC.h"
#import "PinController.h"

@interface PinControllerTest : ViewControllerWithNavBarTestCase {
    PinController *mPinController;
}
@property(readonly) AssetListViewController *vc;

@end

@implementation PinControllerTest

- (AssetListViewController *)vc
{
    return (AssetListViewController *)self.viewController;
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
    
    mPinController = [PinController pinController];
    
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
    
    PinController *new = [PinController pinController];
    Assert(new != saved);
    
    // modal view がでていないことを確認する
    AssertNil(self.vc.modalViewController);
}

- (void)testHasPin
{
    PinController *saved = mPinController;
    
    mPinController.pin = @"1234";
    [mPinController firstPinCheck:self.vc];

    // Pin があるため、この時点ではまだ終了していないはず
    PinController *new = [PinController pinController];
    Assert(new == saved);
    
    // modal view が出ていることを確認する
    UINavigationController *nv = (UINavigationController *)self.vc.modalViewController;
    AssertNotNil(nv);
    PinViewController *vc = (PinViewController *)[nv.viewControllers objectAtIndex:0];
    AssertNotNil(vc);
    
    /*
    [vc _onKeyIn:@"1"];
    [vc _onKeyIn:@"2"];
    [vc _onKeyIn:@"3"];
    [vc _onKeyIn:@"4"];
     */
}

@end
