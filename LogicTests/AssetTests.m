// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import "TestCommon.h"
#import "DataModel.h"

@interface AssetTest : XCTestCase {
    Asset *asset;
}
@end

@implementation AssetTest

- (void)setUp
{
    [super setUp];
    [TestCommon deleteDatabase];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testWithData
{
    [TestCommon installDatabase:@"testdata1"];
    Ledger *ledger = [DataModel ledger];
    AssetEntry *e;

    asset = [ledger assetAtIndex:0];
    AssertEqualInt(1, asset.pid);
    AssertEqualInt(0, asset.type);
    Assert([asset.name isEqualToString:@"Cash"]);
    AssertEqualInt(0, asset.sorder);
    AssertEqualDouble(5000, asset.initialBalance);
    
    AssertEqualInt(4, [asset entryCount]);
    e = [asset entryAt:0];
    AssertEqualDouble(-100, e.value);
    AssertEqualDouble(4900, e.balance);
    e = [asset entryAt:1];
    AssertEqualDouble(-800, e.value);
    AssertEqualDouble(4100, e.balance);
    e = [asset entryAt:2];
    AssertEqualDouble(-100, e.value);
    AssertEqualDouble(4000, e.balance);
    e = [asset entryAt:3];
    AssertEqualDouble(5000, e.value);
    AssertEqualDouble(9000, e.balance);

    asset = [ledger assetAtIndex:1];
    AssertEqualInt(2, asset.pid);
    AssertEqualInt(1, asset.type);
    Assert([asset.name isEqualToString:@"Bank"]);
    AssertEqualInt(1, asset.sorder);
    AssertEqualDouble(100000, asset.initialBalance);

    AssertEqualInt(2, [asset entryCount]);
    e = [asset entryAt:0];
    AssertEqualDouble(-5000, e.value);
    AssertEqualDouble(95000, e.balance);
    e = [asset entryAt:1];
    AssertEqualDouble(100000, e.value);
    AssertEqualDouble(195000, e.balance);

    asset = [ledger assetAtIndex:2];
    AssertEqualInt(3, asset.pid);
    AssertEqualInt(2, asset.type);
    Assert([asset.name isEqualToString:@"Card"]);
    AssertEqualInt(2, asset.sorder);
    AssertEqualDouble(-10000, asset.initialBalance);
    
    AssertEqualInt(1, [asset entryCount]);

    e = [asset entryAt:0];
    AssertEqualDouble( -2100, e.value);
    AssertEqualDouble(-12100, e.balance);
}

// 支払い取引の追加
- (void)testInsertOutgo
{
    // not yet
}

// 入金取引の追加
- (void)testInsertIncome
{
    // not yet
}

// 残高調整の追加
- (void)testInsertAdjustment
{
    [TestCommon installDatabase:@"testdata1"];
    Ledger *ledger = [DataModel ledger];
    asset = [ledger assetAtIndex:0];
    
    AssertEqualDouble(9000, [asset lastBalance]);

    // 新規エントリ
    AssetEntry *ae = [[AssetEntry alloc] initWithTransaction:nil withAsset:asset];

    ae.assetKey = asset.pid;
    ae.transaction.type = TYPE_ADJ;
    [ae setEvalue:10000.0];
    ae.transaction.date = [TestCommon dateWithString:@"20090201000000"];

    [asset insertEntry:ae];
    AssertEqualDouble(10000, [asset lastBalance]);
}

// 資産間移動の追加
- (void)testInsertTransfer
{
    // not yet
}

// 初期残高変更処理
- (void)testChangeInitialBalance
{
    [TestCommon installDatabase:@"testdata1"];
    Ledger *ledger = [DataModel ledger];
    asset = [ledger assetAtIndex:0];

    AssertEqualDouble(5000, [asset initialBalance]);
    AssertEqualDouble(9000, [asset lastBalance]);
    
    asset.initialBalance = 0.0;
    [asset rebuild];
    AssertEqualDouble(0, [asset initialBalance]);

    AssetEntry *e;
    e = [asset entryAt:0];
    AssertEqualDouble(e.balance, -100);
    e = [asset entryAt:1];
    AssertEqualDouble(e.balance, -900);    
    e = [asset entryAt:2];
    AssertEqualDouble(e.balance, 4000);    // 残高調整のため、balance 変化なし
    AssertEqualDouble(e.value, 4900);
    
    AssertEqualDouble(9000, [asset lastBalance]);
}

// 取引削除
- (void)testDeleteEntryAt
{
    [TestCommon installDatabase:@"testdata1"];
    Ledger *ledger = [DataModel ledger];
    
    asset = [ledger assetAtIndex:0];
    AssertEqualDouble(5000, asset.initialBalance);

    [asset deleteEntryAt:3]; // 資産間移動取引を削除する

    AssertEqualInt(3, [asset entryCount]);
    AssertEqualDouble(5000, asset.initialBalance);

    // 別資産の取引数が減って「いない」ことを確認(置換されているはず)
    AssertEqualInt(2, [[ledger assetAtIndex:1] entryCount]);

    // データベースが更新されていることを確認する
    [DataModel load];
    AssertEqualInt(3, [asset entryCount]);
    AssertEqualInt(2, [[ledger assetAtIndex:1] entryCount]);
}

// 先頭取引削除
-(void)testDeleteFirstEntry
{
    // not yet
}

// 古い取引削除
- (void)testDeleteOldEntriesBefore
{
    [TestCommon installDatabase:@"testdata1"];
    Ledger *ledger = [DataModel ledger];
    AssetEntry *e;
    NSDate *date;

    asset = [ledger assetAtIndex:0];
    AssertEqualInt(4, [asset entryCount]);

    // 最初よりも早い日付の場合に何も削除されないこと
    date = [TestCommon dateWithString:@"20081231000000"];
    [asset deleteOldEntriesBefore:date];
    AssertEqualInt(4, [asset entryCount]);    

    // 途中削除
    e = [asset entryAt:2];
    [asset deleteOldEntriesBefore:e.transaction.date];
    AssertEqualInt(2, [asset entryCount]);    

    // 最後の日付の後で削除
    date = [TestCommon dateWithString:@"20090201000000"];
    [asset deleteOldEntriesBefore:date];
    AssertEqualInt(0, [asset entryCount]);

    // 残高チェック
    AssertEqualDouble(9000, asset.initialBalance);

    // データベースが更新されていることを確認する
    [DataModel load];
    AssertEqualInt(0, [asset entryCount]);
    AssertEqualDouble(9000, asset.initialBalance);
}

// replace : 日付変更、種別変更なし
// replace : 通常から資産間移動に変更
// replace : 資産間移動のままだけど相手資産変更
// replace : 資産間移動のままだけど相手資産変更(dstAsset側)
// replace : 資産間移動から通常に変更
// replace : 資産間移動から通常に変更(dstAsset側)

@end
