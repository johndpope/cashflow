// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
#import <UIKit/UIKit.h>
#import "Database.h"

#define PKEY @"key"

@interface ORRecord : NSObject
{
    int mPid;
    BOOL mIsInserted;
}

@property(nonatomic,assign) int pid;

+ (BOOL)migrate:(NSArray *)array;
+ (NSMutableArray *)find_all;
+ (NSMutableArray *)find_cond:(NSString *)cond;
+ (id)find:(int)id;

- (void)save;
- (void)insert;
- (void)update;
- (void)delete;
+ (void)delete_all;

+ (NSString *)tableName;

@end


