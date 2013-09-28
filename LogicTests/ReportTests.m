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
    
    mReports = [[Report alloc] init];
}

- (void)tearDown
{
    mReports = nil;
}

- (void)testMonthly
{
    [mReports generate:REPORT_MONTHLY asset:nil];

    AssertEqualInt(1, [mReports.reportEntries count]);
    ReportEntry *report = [mReports.reportEntries objectAtIndex:0];

    //NSString *s = [TestCommon stringWithDate:report.date];
    //Assert([s isEqualToString:@"200901010000"]);
    AssertEqualDouble(100000, report.totalIncome);
    AssertEqualDouble(-3100, report.totalOutgo);
}


@end
