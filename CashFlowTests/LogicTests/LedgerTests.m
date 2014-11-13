// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import "TestCommon.h"

@interface LedgerTest : XCTestCase {
    Ledger *ledger;
}
@end

@implementation LedgerTest

- (void)setUp
{
    [TestCommon deleteDatabase];
    [[DataModel instance] load];
    ledger = [DataModel ledger];
}

- (void)tearDown
{
}

- (void)testInitial
{
    // 現金のみがあるはず
    XCTAssertEqual([ledger.assets count], 1);
    [ledger load];
    [ledger rebuild];
    XCTAssertEqual([ledger.assets count], 1);

    Asset *asset = [ledger assetAtIndex:0];
    XCTAssertEqual(0, [asset entryCount]);
}

- (void)testNormal
{
    [TestCommon installDatabase:@"testdata1"];
    ledger = [DataModel ledger];
    
    // 現金のみがあるはず
    XCTAssertEqual([ledger.assets count], 3);
    [ledger load];
    [ledger rebuild];
    XCTAssertEqual([ledger.assets count],3);

    XCTAssertEqual(4, [[ledger assetAtIndex:0] entryCount]);
    XCTAssertEqual(2, [[ledger assetAtIndex:1] entryCount]);
    XCTAssertEqual(1, [[ledger assetAtIndex:2] entryCount]);
}

@end
