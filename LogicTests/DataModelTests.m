// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import "TestCommon.h"

@interface DataModelTest : XCTestCase {
    DataModel *dm;
}
@end


@implementation DataModelTest

- (void)setUp
{
    [TestCommon initDatabase];
    dm = [DataModel instance];
}

- (void)tearDown
{
}

#pragma mark -
#pragma mark Tests

// データベースがないときに、初期化されること
- (void)testInitial
{
    // 初期データチェック
    Assert(dm != nil);
    AssertEqualInt(0, [dm.journal.entries count]);

    Asset *as = [dm.ledger.assets objectAtIndex:0];
    AssertEqualObjects(NSLocalizedString(@"Cash", nil), as.name);
                  
    AssertEqualInt(0, [dm.categories count]);
}

// データベースがあるときに、正常に読み込めること
- (void)testNotInitial
{
    [TestCommon installDatabase:@"testdata1"];
    dm = [DataModel instance];

    AssertEqual(6, (int)[dm.journal.entries count]);
    AssertEqual(3, (int)[dm.ledger.assets count]);
    AssertEqual(3, (int)[dm.categories count]);
}

@end
