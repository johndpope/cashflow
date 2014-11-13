// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import "TestCommon.h"
#import "DataModel.h"
#import "DescLRUManager.h"

@interface DescLRUManagerTests : XCTestCase {
    DescLRUManager *manager;
}
@end

@implementation DescLRUManagerTests

- (void)setUp
{
    [super setUp];
    [TestCommon deleteDatabase];

    [[DataModel instance] load]; // re-create DataModel
}

- (void)tearDown
{
    [super tearDown];
    
    [DataModel finalize];
    [Database shutdown];
}

- (void)setupTestData
{
    Database *db = [Database instance];
     
    [DescLRUManager addDescLRU:@"test0" category:0 date:[db dateFromString:@"20100101000000"]];
    [DescLRUManager addDescLRU:@"test1" category:1 date:[db dateFromString:@"20100101000001"]];
    [DescLRUManager addDescLRU:@"test2" category:2 date:[db dateFromString:@"20100101000002"]];
    [DescLRUManager addDescLRU:@"test3" category:0 date:[db dateFromString:@"20100101000003"]];
    [DescLRUManager addDescLRU:@"test4" category:1 date:[db dateFromString:@"20100101000004"]];
    [DescLRUManager addDescLRU:@"test5" category:2 date:[db dateFromString:@"20100101000005"]];
}

- (void) testInit {
    NSMutableArray *ary = [DescLRUManager getDescLRUs:-1];
    XCTAssertEqual(0, (int)[ary count], @"LRU count must be 0.");
}

- (void)testAnyCategory
{
    [self setupTestData];
    
    NSMutableArray *ary;
    ary = [DescLRUManager getDescLRUs:-1];
    XCTAssertEqual(6, (int)[ary count], @"LRU count must be 6.");

    DescLRU *lru;
    lru = ary[0];
    XCTAssertEqualObjects(@"test5", lru.desc, @"first entry");
    lru = ary[5];
    XCTAssertEqualObjects(@"test0", lru.desc, @"last entry");
}

- (void)testCategory
{
    [self setupTestData];

    NSMutableArray *ary;
    ary = [DescLRUManager getDescLRUs:1];
    XCTAssertEqual(2, (int)[ary count], @"LRU count must be 2.");

    DescLRU *lru;
    lru = ary[0];
    XCTAssertEqualObjects(@"test4", lru.desc, @"first entry");
    lru = ary[1];
    XCTAssertEqualObjects(@"test1", lru.desc, @"last entry");
}

- (void)testUpdateSameCategory
{
    [self setupTestData];

    [DescLRUManager addDescLRU:@"test1" category:1]; // same name/cat.

    NSMutableArray *ary;
    ary = [DescLRUManager getDescLRUs:1];
    XCTAssertEqual(2, (int)[ary count], @"LRU count must be 2.");

    DescLRU *lru;
    lru = ary[0];
    XCTAssertEqualObjects(@"test1", lru.desc, @"first entry");
    lru = ary[1];
    XCTAssertEqualObjects(@"test4", lru.desc, @"last entry");
}

- (void)testUpdateOtherCategory
{
    [self setupTestData];

    [DescLRUManager addDescLRU:@"test1" category:2]; // same name/other cat.

    NSMutableArray *ary;
    ary = [DescLRUManager getDescLRUs:1];
    XCTAssertEqual(1, (int)[ary count], @"LRU count must be 2.");

    DescLRU *lru;
    lru = ary[0];
    XCTAssertEqualObjects(@"test4", lru.desc, @"first entry");

    ary = [DescLRUManager getDescLRUs:2];
    XCTAssertEqual(3, (int)[ary count], @"LRU count must be 3.");
    lru = ary[0];
    XCTAssertEqualObjects(@"test1", lru.desc, @"new entry");
}

@end
