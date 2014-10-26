// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import "TestCommon.h"

@interface AssetEntryTest : XCTestCase {
}

@end


@implementation AssetEntryTest

- (void)setUp
{
}

- (void)tearDown
{
}

#pragma mark -
#pragma mark Helpers


#pragma mark -
#pragma mark Tests

// transaction 指定なし
- (void)testAllocNew
{
    AssetEntry *e;
    Asset *a = [Asset new];
    a.pid = 999;

    e = [[AssetEntry alloc] initWithTransaction:nil withAsset:a];

    XCTAssertEqual(e.assetKey, 999);
    XCTAssertEqual(e.value, 0.0);
    XCTAssertEqual(e.balance, 0.0);
    XCTAssertEqual(e.transaction.asset, 999);
    XCTAssertFalse([e isDstAsset]);

    // 値設定
    e.value = 200.0;
    //[e setupTransaction];
    XCTAssertEqual(e.transaction.value, 200.0);
}

// transaction 指定あり、通常
- (void)testAllocExisting
{
    Asset *a = [Asset new];
    a.pid = 111;
    Transaction *t = [Transaction new];
    t.type = TYPE_TRANSFER;
    t.asset = 111;
    t.dstAsset = 222;
    t.value = 10000.0;

    AssetEntry *e = [[AssetEntry alloc] initWithTransaction:t withAsset:a];

    XCTAssertEqual(e.assetKey, 111);
    XCTAssertEqual(e.value, 10000.0);
    XCTAssertEqual(e.balance, 0.0);
    XCTAssertEqual(e.transaction.asset, 111);
    XCTAssertFalse([e isDstAsset]);

    // 値設定
    e.value = 200.0;
    //[e setupTransaction];
    XCTAssertEqual(e.transaction.value, 200.0);
}

// transaction 指定あり、逆
- (void)testAllocExistingReverse
{
    Asset *a = [Asset new];
    a.pid = 111;
    Transaction *t = [Transaction new];
    t.type = TYPE_TRANSFER;
    t.asset = 222;
    t.dstAsset = 111;
    t.value = 10000.0;

    AssetEntry *e = [[AssetEntry alloc] initWithTransaction:t withAsset:a];

    XCTAssertEqual(e.assetKey, 111);
    XCTAssertEqual(e.value, -10000.0);
    XCTAssertEqual(e.balance, 0.0);
    XCTAssertEqual(e.transaction.asset, 222);
    XCTAssert([e isDstAsset]);

    // 値設定
    e.value = 200.0;
    //[e setupTransaction];
    XCTAssertEqual(e.transaction.value, -200.0);
}

- (void)testEvalueNormal
{
    Asset *a = [Asset new];
    a.pid = 111;
    Transaction *t = [Transaction new];
    t.asset = 111;
    t.dstAsset = -1;

    AssetEntry *e = [[AssetEntry alloc] initWithTransaction:t withAsset:a];
    e.balance = 99999.0;

    t.type = TYPE_INCOME;
    e.value = 10000;
    XCTAssertEqual(e.evalue, 10000.0);
    e.evalue = 20000;
    XCTAssertEqual(e.transaction.value, 20000.0);

    t.type = TYPE_OUTGO;
    e.value = 10000;
    XCTAssertEqual(e.evalue, -10000.0);
    e.evalue = 20000;
    XCTAssertEqual(e.transaction.value, -20000.0);

    t.type = TYPE_ADJ;
    e.balance = 99999;
    XCTAssertEqual([e evalue], 99999.0);
    e.evalue = 88888;
    XCTAssertEqual(e.balance, 88888.0);

    t.type = TYPE_TRANSFER;
    e.value = 10000;
    XCTAssertEqual([e evalue], -10000.0);
    e.evalue = 20000;
    XCTAssertEqual(e.transaction.value, -20000.0);
}

@end
