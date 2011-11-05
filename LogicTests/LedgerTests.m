// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import "TestCommon.h"

@interface LedgerTest : SenTestCase {
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
    Assert([ledger.assets count] == 1);
    [ledger load];
    [ledger rebuild];
    Assert([ledger.assets count] == 1);

    Asset *asset = [ledger assetAtIndex:0];
    AssertEqualInt(0, [asset entryCount]);
}

- (void)testNormal
{
    [TestCommon installDatabase:@"testdata1"];
    ledger = [DataModel ledger];
    
    // 現金のみがあるはず
    Assert([ledger.assets count] == 3);
    [ledger load];
    [ledger rebuild];
    Assert([ledger.assets count] == 3);

    AssertEqualInt(4, [[ledger assetAtIndex:0] entryCount]);
    AssertEqualInt(2, [[ledger assetAtIndex:1] entryCount]);
    AssertEqualInt(1, [[ledger assetAtIndex:2] entryCount]);
}

@end
