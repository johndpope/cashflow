// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import "TestCommon.h"

@interface TransactionTest : XCTestCase {
    Transaction *transaction;
}
@end

@implementation TransactionTest

- (void)setUp
{
    [super setUp];
    [TestCommon deleteDatabase];
    [[DataModel instance] load];
}

- (void)tearDown
{
    [super tearDown];
}

// 日付のアップグレードテスト (ver 3.2.1 -> 3.3以降 へのアップグレード)
- (void)testMigrateDate
{
    Database *db = [Database instance];
    
    // 旧バージョンのフォーマットでデータを作成
    [db beginTransaction];
    for (int i = 0; i < 100; i++) {
        [db exec:@"INSERT INTO Transactions VALUES(NULL, 0, 0, 200901011356, 0, 0, 0, '', '');"];
        [db exec:@"INSERT INTO Transactions VALUES(NULL, 0, 0, '20090101午後0156', 0, 0, 0, '', '');"];
    }
    [db commitTransaction];
    
    // Migrate 実行
    [DataModel finalize];
    [[DataModel instance] load];
    
    // チェック
    dbstmt *stmt = [db prepare:@"SELECT date FROM Transactions;"];
    XCTAssertEqual(SQLITE_ROW, [stmt step]);
    do {
        NSString *s = [stmt colString:0];
        AssertEqualObjects(@"20090101135600", s);
    } while ([stmt step] == SQLITE_ROW);
}

// 最終使用日のテスト
- (void)testLastUsedDate
{
    // 解除
    [Transaction setLastUsedDate:nil];
    AssertFalse([Transaction hasLastUsedDate]);

    NSDate *t = [NSDate dateWithTimeIntervalSince1970:0];
    [Transaction setLastUsedDate:t];
    Assert([Transaction hasLastUsedDate]);
    NSDate *t2 = [Transaction lastUsedDate];
    Assert([t2 isEqualToDate:t]);
}

@end
