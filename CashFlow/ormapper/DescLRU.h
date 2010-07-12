// Generated by O/R mapper generator ver 0.1

#import <UIKit/UIKit.h>
#import "ORRecord.h"

@interface DescLRU : ORRecord {
    NSString* description;
    NSDate* lastUse;
}

@property(nonatomic,retain) NSString* description;
@property(nonatomic,retain) NSDate* lastUse;

+ (BOOL)migrate;

+ (id)allocator;
+ (NSMutableArray *)find_cond:(NSString *)cond;
+ (dbstmt *)gen_stmt:(NSString *)cond;
+ (NSMutableArray *)find_stmt:(dbstmt *)cond;
+ (DescLRU *)find:(int)pid;
- (void)delete;
+ (void)delete_cond:(NSString *)cond;
+ (void)delete_all;

// internal functions
+ (NSString *)tableName;
- (void)insert;
- (void)update;
- (void)_loadRow:(dbstmt *)stmt;

@end
