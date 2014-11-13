// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import "TestCommon.h"
#import "PinVC.h"

@interface PinViewControllerTest : ViewControllerWithNavBarTestCase <PinViewDelegate> {
    BOOL mCheckResult;
    BOOL mIsCanceled;
    BOOL mIsFinished;
}
@property(readonly) PinViewController *vc;

@end

@implementation PinViewControllerTest

- (PinViewController *)vc
{
    return (PinViewController *)self.viewController;
}

#pragma mark UIViewControllerTest methods

- (NSString *)viewControllerName
{
    return @"PinViewController";
}

- (NSString *)viewControllerNibName
{
    return @"PinView";
}

- (BOOL)hasNavigationController
{
    return YES;
}

#pragma mark - PinViewDelegate

- (void)pinViewFinished:(PinViewController *)vc isCancel:(BOOL)isCancel
{
    mIsFinished = YES;
    mIsCanceled = isCancel;
}

- (BOOL)pinViewCheckPin:(PinViewController *)vc
{
    if ([vc.value isEqualToString:@"1234"]) {
        return true;
    }
    return false;
}

#pragma mark -

- (void)setUp
{
    [super setUp];
    
    mIsFinished = NO;
    mIsCanceled = NO;
    self.vc.delegate = self;
    
    [self.vc viewDidLoad]; // ###
    [self.vc viewWillAppear:YES]; // ###
}

- (void)tearDown
{
    //[vc viewWillDisappear:YES];
    [super tearDown];
}

- (void)testInitial
{
    XCTAssertEqualObjects(@"", self.vc.value);
    
    XCTAssertNotNil(self.vc.navigationItem.rightBarButtonItem);
    XCTAssertNil(self.vc.navigationItem.leftBarButtonItem);
}

- (void)testCancellable
{
    self.vc.enableCancel = YES;
    [self.vc viewDidLoad];
    
    XCTAssertNotNil(self.vc.navigationItem.rightBarButtonItem);
    XCTAssertNotNil(self.vc.navigationItem.leftBarButtonItem);
}


- (void)testCancel
{
    [self.vc cancelAction:nil];
    XCTAssert(mIsFinished);
    XCTAssert(mIsCanceled);
}

- (void)testFinish
{
    [self.vc doneAction:nil];
    XCTAssert(mIsFinished);
    XCTAssertFalse(mIsCanceled);
}

- (void)testAutoFinish
{
    [self.vc onKeyIn:@"1"];
    [self.vc onKeyIn:@"2"];
    [self.vc onKeyIn:@"3"];
    XCTAssertFalse(mIsFinished);
    [self.vc onKeyIn:@"4"];
    XCTAssert(mIsFinished);
    XCTAssertFalse(mIsCanceled);
}

@end
