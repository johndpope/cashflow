// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "CashFlow-Swift.h" // Bridge

#import "ViewControllerTestCase.h"

#import "Database.h"
#import "DataModel.h"
#import "DateFormatter2.h"

#define NOTYET STFail(@"not yet")

// Simplefied macros
//#define Assert(x) XCTAssertTrue(x)
//#define AssertTrue(x) XCTAssertTrue(x, @"")
//#define AssertFalse(x) XCTAssertFalse(x, @"")
//#define AssertNil(x) XCTAssertNil(x, @"")
//#define AssertNotNil(x) XCTAssertNotNil(x, @"")
//#define AssertEqual(a, b) XCTAssertEqual(a, b, @"")
//#define AssertEqualInt(a, b) XCTAssertEqual((int)(a), (int)(b), @"")
//#define AssertEqualDouble(a, b) XCTAssertEqual((double)(a), (double)(b), @"")
//#define AssertEqualObjects(a, b) XCTAssertEqualObjects(a, b, @"")

@interface TestCommon : NSObject
{
}

+ (NSDate *)dateWithString:(NSString *)s;
+ (NSString *)stringWithDate:(NSDate *)date;

+ (void)deleteDatabase;
+ (void)initDatabase;
+ (BOOL)installDatabase:(NSString *)sqlFileName;

+ (void)_setupTestDbName;
+ (void)_createDocumentsDir;

@end
