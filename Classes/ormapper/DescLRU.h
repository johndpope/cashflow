// Generated by O/R mapper generator ver 0.1(cashflow)

#import <UIKit/UIKit.h>
#import "ORRecord.h"

@interface DescLRU : ORRecord {
    NSString* mDescription;
    NSDate* mLastUse;
    int mCategory;
}

@property(nonatomic,retain) NSString* description;
@property(nonatomic,retain) NSDate* lastUse;
@property(nonatomic,assign) int category;

+ (BOOL)migrate;

+ (id)allocator;

// CRUD (Create/Read/Update/Delete) operations

// Create operations
- (void)insert;

// Read operations
+ (DescLRU *)find:(int)pid;
+ (NSMutableArray *)find_cond:(NSString *)cond;
+ (dbstmt *)gen_stmt:(NSString *)cond;
+ (NSMutableArray *)find_stmt:(dbstmt *)cond;

// Update operations
- (void)update;

// Delete operations
- (void)delete;
+ (void)delete_cond:(NSString *)cond;
+ (void)delete_all;

// internal functions
+ (NSString *)tableName;
- (void)_loadRow:(dbstmt *)stmt;

@end
