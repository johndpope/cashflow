// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import "TestCommon.h"
#import "DataModel.h"
#import "Report.h"

@interface ReportTest : XCTestCase {
    Report *mReports;
}
@end

@implementation ReportTest

- (void)setUp
{
    [TestCommon installDatabase:@"testdata1"];
    [DataModel instance];
    
    mReports = [Report new];
}

- (void)tearDown
{
    mReports = nil;
}

- (void)testMonthly
{
    [mReports generate:REPORT_MONTHLY asset:nil];

    XCTAssertEqual(1, [mReports.reportEntries count]);
    ReportEntry *report = [mReports.reportEntries objectAtIndex:0];

    //NSString *s = [TestCommon stringWithDate:report.date];
    //Assert([s isEqualToString:@"200901010000"]);
    XCTAssertEqual(100000.0, report.totalIncome);
    XCTAssertEqual(-3100.0, report.totalOutgo);
}


@end
