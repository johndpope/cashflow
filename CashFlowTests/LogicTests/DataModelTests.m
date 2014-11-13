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
    XCTAssert(dm != nil);
    XCTAssertEqual(0, [dm.journal.entries count]);

    Asset *as = (dm.ledger.assets)[0];
    XCTAssertEqualObjects(NSLocalizedString(@"Cash", nil), as.name);
                  
    XCTAssertEqual(0, [dm.categories count]);
}

// データベースがあるときに、正常に読み込めること
- (void)testNotInitial
{
    [TestCommon installDatabase:@"testdata1"];
    dm = [DataModel instance];

    XCTAssertEqual(6, (int)[dm.journal.entries count]);
    XCTAssertEqual(3, (int)[dm.ledger.assets count]);
    XCTAssertEqual(3, (int)[dm.categories count]);
}

@end
