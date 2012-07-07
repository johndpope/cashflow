// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <SenTestingKit/SenTestingKit.h>

@interface ArcBugTest : SenTestCase {
}

@end

@implementation ArcBugTest

- (void)testArcBug
{
#if !__has_feature(objc_arc)
    STFail(@"ARC not enabled");
#endif

    UIButton *b, *b1, *b2;
    
    for (int i = 0; i < 2; i++) {
        b = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        if (i == 0) {
            b1 = b;
        } else {
            b2 = b;
        }
    } 

    STAssertTrue(YES, @"Ok if test is not crashed.");
}

@end
