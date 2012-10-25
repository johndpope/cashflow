// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import "TestCommon.h"

@interface JournalTest : SenTestCase {
    Journal *journal;
}
@end

@implementation JournalTest

- (void)setUp
{
    [super setUp];
    [TestCommon initDatabase];
    journal = [DataModel journal];
}

- (void)tearDown
{
    [super tearDown];
}


- (void)testReload
{
    AssertEqualInt(0, [journal.entries count]);
    [journal reload];
    AssertEqualInt(0, [journal.entries count]);
    
    [TestCommon installDatabase:@"testdata1"];
    journal = [DataModel journal];
    AssertEqualInt(6, [journal.entries count]);

    [journal reload];
    AssertEqualInt(6, [journal.entries count]);
}

- (void)testFastEnumeration
{
    [TestCommon installDatabase:@"testdata1"];
    journal = [DataModel journal];
    
    int i = 1;
    for (Transaction *t in journal) {
        AssertEqualInt(i, t.pid);
        i++;
    }
}

- (void)testInsertTransaction
{
    [TestCommon installDatabase:@"testdata1"];
    journal = [DataModel journal];

    // 途中に挿入する
    Transaction *t = [Transaction new];
    t.pid = 7;
    t.asset = 1;
    t.type = 0;
    t.value = 100;
    t.date = [TestCommon dateWithString:@"20090103000000"];
    
    [journal insertTransaction:t];
    AssertEqualInt(7, [journal.entries count]);
    Transaction *tt = [journal.entries objectAtIndex:2];
    AssertEqualObjects(t, tt);
    AssertEqualInt(t.pid, tt.pid);
}

- (void)testReplaceTransaction
{
    [TestCommon installDatabase:@"testdata1"];
    journal = [DataModel journal];

    // 途中に挿入する
    Transaction *t = [Transaction new];
    t.pid = 999;
    t.asset = 3;
    t.type = 0;
    t.value = 100;
    t.date = [TestCommon dateWithString:@"20090201000000"]; // last
    
    Transaction *orig = [journal.entries objectAtIndex:3];
    AssertEqualInt(4, orig.pid);

    [journal replaceTransaction:orig withObject:t];

    AssertEqualInt(6, [journal.entries count]); // 数は変更なし
    Transaction *tt = [journal.entries objectAtIndex:5];
    //ASSERT_EQUAL(t, tt);
    AssertEqualInt(t.pid, tt.pid);
}

- (void)testDeleteTransaction
{
    [TestCommon installDatabase:@"testdata1"];
    journal = [DataModel journal];
    Asset *asset = [Asset new];

    // 資産間取引を削除 (pid == 4 の取引)
    asset.pid = 2;
    Transaction *t = [journal.entries objectAtIndex:3];
    Assert(![journal deleteTransaction:t withAsset:asset]);
    AssertEqualInt(6, [journal.entries count]); // 置換されたので消えてないはず
    
    t = [journal.entries objectAtIndex:2];
    AssertEqualInt(3, t.pid);
    t = [journal.entries objectAtIndex:3];
    AssertEqualInt(4, t.pid); // まだ消えてない
    
    // 置換されていることを確認する
    AssertEqualInt(1, t.asset);
    AssertEqualInt(-1, t.dstAsset);
    AssertEqualDouble(5000, t.value);
    
    // 今度は置換された資産間取引を消す
    asset.pid = 1;
    Assert([journal deleteTransaction:t withAsset:asset]);
    
    t = [journal.entries objectAtIndex:2];
    AssertEqualInt(3, t.pid);
    t = [journal.entries objectAtIndex:3];
    AssertEqualInt(5, t.pid);
}

- (void)testDeleteTransaction2
{
    [TestCommon installDatabase:@"testdata1"];
    journal = [DataModel journal];
    Asset *asset = [Asset new];
    
    // 資産間取引を削除 (pid == 4 の取引)、ただし、testDeleteTransaction とは逆方向
    asset.pid = 1;
    Transaction *t = [journal.entries objectAtIndex:3];
    Assert(![journal deleteTransaction:t withAsset:asset]);
    
    // 置換されていることを確認する
    AssertEqualInt(2, t.asset);
    AssertEqualInt(-1, t.dstAsset);
    AssertEqualDouble(-5000, t.value);
    
    // 置換された資産間取引を消す
    asset.pid = 2;
    Assert([journal deleteTransaction:t withAsset:asset]);
    
    t = [journal.entries objectAtIndex:2];
    AssertEqualInt(3, t.pid);
    t = [journal.entries objectAtIndex:3];
    AssertEqualInt(5, t.pid);
}

- (void)testDeleteTransactionWithAsset
{
    [TestCommon installDatabase:@"testdata1"];
    journal = [DataModel journal];
    Asset *asset = [Asset new];

    AssertEqualInt(6, [journal.entries count]);

    asset.pid = 4; // not exist
    [journal deleteAllTransactionsWithAsset:asset];
    AssertEqualInt(6, [journal.entries count]);
    
    asset.pid = 1;
    [journal deleteAllTransactionsWithAsset:asset];
    AssertEqualInt(3, [journal.entries count]);
    
    asset.pid = 2;
    [journal deleteAllTransactionsWithAsset:asset];
    AssertEqualInt(1, [journal.entries count]);

    asset.pid = 3;
    [journal deleteAllTransactionsWithAsset:asset];
    AssertEqualInt(0, [journal.entries count]);
}

// Journal 上限数チェック
#if 0
- (void)testJournalInsertUpperLimit
{
    Assert([journal.entries count] == 0);

    Transaction *t;
    int i;

    for (i = 0; i < MAX_TRANSACTIONS; i++) {
        t = [Transaction new];
        t.asset = 1; // cash
        [journal insertTransaction:t];
        [t release];

        Assert([journal.entries count] == i + 1);
    }

    Ledger *ledger = [DataModel ledger];
    [ledger rebuild];
    Asset *asset = [ledger assetAtIndex:0];
    Assert([asset entryCount] == MAX_TRANSACTIONS);
    
    // 上限数＋１個目
    t = [Transaction new];
    t.asset = 1; // cash
    [journal insertTransaction:t];
    [t release];

    Assert([journal.entries count] == MAX_TRANSACTIONS);
}
#endif

@end
