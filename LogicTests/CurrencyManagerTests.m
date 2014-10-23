// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import "TestCommon.h"
#import "DataModel.h"
#import "Report.h"

@interface CurrencyManagerTests : XCTestCase {
    CurrencyManager *manager;
}
@end

@implementation CurrencyManagerTests

- (void)setUp
{
    manager = [CurrencyManager instance];
}

- (void)tearDown
{
}

- (void) testInit {
    XCTAssertNotNil(manager);
}

- (void)testSystem
{
    [manager setBaseCurrency:nil];
    NSString *s = [CurrencyManager formatCurrency:1234.56];
    //AssertEqualObjects(s, @"$1,234.56");
    XCTAssert([s isEqualToString:@"￥1,235"] || [s isEqualToString:@"$1,234.56"]);
}

- (void)testUSD
{
    [manager setBaseCurrency:@"USD"];
    NSString *s = [CurrencyManager formatCurrency:1234.56];
    XCTAssertEqualObjects(@"$1,234.56", s);
}

- (void)testJPY
{
    [manager setBaseCurrency:@"JPY"];
    NSString *s = [CurrencyManager formatCurrency:1234];
    //AssertEqualObjects(@"¥1,234", s);
    XCTAssertEqualObjects(@"￥1,234", s);
}

- (void)testEUR
{
    [manager setBaseCurrency:@"EUR"];
    NSString *s = [CurrencyManager formatCurrency:1234.56];
    XCTAssertEqualObjects(@"€1,234.56", s);
}

- (void)testOther
{
    [manager setBaseCurrency:@"CAD"];
    NSString *s = [CurrencyManager formatCurrency:1234.56];
    XCTAssertEqualObjects(@"CA$1,234.56", s);
}

@end

