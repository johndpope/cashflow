// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <SenTestingKit/SenTestingKit.h>

#import "ViewControllerTestCase.h"

#import "Database.h"
#import "DataModel.h"
#import "DateFormatter2.h"

#define NOTYET STFail(@"not yet")

// Simplefied macros
#define Assert(x) STAssertTrue(x, @"")
#define AssertTrue(x) STAssertTrue(x, @"")
#define AssertFalse(x) STAssertFalse(x, @"")
#define AssertNil(x) STAssertNil(x, @"")
#define AssertNotNil(x) STAssertNotNil(x, @"")
#define AssertEquals(a, b) STAssertEquals(a, b, @"")
#define AssertEqualInt(a, b) STAssertEquals((int)(a), (int)(b), @"")
#define AssertEqualDouble(a, b) STAssertEquals((double)(a), (double)(b), @"")
#define AssertEqualObjects(a, b) STAssertEqualObjects(a, b, @"")

@interface TestCommon : NSObject
{
}

+ (NSDate *)dateWithString:(NSString *)s;
+ (NSString *)stringWithDate:(NSDate *)date;

+ (void)deleteDatabase;
+ (void)initDatabase;
+ (BOOL)installDatabase:(NSString *)sqlFileName;

+ (void)_createDocumentsDir;

@end
