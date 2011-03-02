// Generated by O/R mapper generator ver 0.1(cashflow)

#import "Database.h"
#import "DescLRU.h"

@implementation DescLRU

@synthesize description = mDescription;
@synthesize lastUse = mLastUse;
@synthesize category = mCategory;

- (id)init
{
    self = [super init];
    return self;
}

- (void)dealloc
{
    [description release];
    [lastUse release];
    [super dealloc];
}

/**
  @brief Migrate database table

  @return YES - table was newly created, NO - table already exists
*/

+ (BOOL)migrate
{
    NSArray *columnTypes = [NSArray arrayWithObjects:
        @"description", @"TEXT",
        @"lastUse", @"DATE",
        @"category", @"INTEGER",
        nil];

    return [super migrate:columnTypes];
}

/**
  @brief allocate entry
*/
+ (id)allocator
{
    id e = [[[DescLRU alloc] init] autorelease];
    return e;
}

#pragma mark Read operations

/**
  @brief get the record matchs the id

  @param pid Primary key of the record
  @return record
*/
+ (DescLRU *)find:(int)pid
{
    Database *db = [Database instance];

    dbstmt *stmt = [db prepare:@"SELECT * FROM DescLRUs WHERE key = ?;"];
    [stmt bindInt:0 val:pid];
    if ([stmt step] != SQLITE_ROW) {
        return nil;
    }

    DescLRU *e = [self allocator];
    [e _loadRow:stmt];
 
    return e;
}

/**
  @brief get all records matche the conditions

  @param cond Conditions (WHERE phrase and so on)
  @return array of records
*/
+ (NSMutableArray *)find_cond:(NSString *)cond
{
    dbstmt *stmt = [self gen_stmt:cond];
    NSMutableArray *array = [self find_stmt:stmt];
    return array;
}

/**
  @brief create dbstmt

  @param s condition
  @return dbstmt
*/
+ (dbstmt *)gen_stmt:(NSString *)cond
{
    NSString *sql;
    if (cond == nil) {
        sql = @"SELECT * FROM DescLRUs;";
    } else {
        sql = [NSString stringWithFormat:@"SELECT * FROM DescLRUs %@;", cond];
    }  
    dbstmt *stmt = [[Database instance] prepare:sql];
    return stmt;
}

/**
  @brief get all records matche the conditions

  @param stmt Statement
  @return array of records
*/
+ (NSMutableArray *)find_stmt:(dbstmt *)stmt
{
    NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];

    while ([stmt step] == SQLITE_ROW) {
        DescLRU *e = [self allocator];
        [e _loadRow:stmt];
        [array addObject:e];
    }
    return array;
}

- (void)_loadRow:(dbstmt *)stmt
{
    self.pid = [stmt colInt:0];
    self.description = [stmt colString:1];
    self.lastUse = [stmt colDate:2];
    self.category = [stmt colInt:3];

    mIsInserted = YES;
}

#pragma mark Create operations

- (void)insert
{
    [super insert];

    Database *db = [Database instance];
    dbstmt *stmt;
    
    //[db beginTransaction];
    stmt = [db prepare:@"INSERT INTO DescLRUs VALUES(NULL,?,?,?);"];

    [stmt bindString:0 val:mDescription];
    [stmt bindDate:1 val:mLastUse];
    [stmt bindInt:2 val:mCategory];
    [stmt step];

    self.pid = [db lastInsertRowId];

    //[db commitTransaction];
    mIsInserted = YES;
}

#pragma mark Update operations

- (void)update
{
    [super update];

    Database *db = [Database instance];
    //[db beginTransaction];

    dbstmt *stmt = [db prepare:@"UPDATE DescLRUs SET "
        "description = ?"
        ",lastUse = ?"
        ",category = ?"
        " WHERE key = ?;"];
    [stmt bindString:0 val:mDescription];
    [stmt bindDate:1 val:mLastUse];
    [stmt bindInt:2 val:mCategory];
    [stmt bindInt:3 val:mPid];

    [stmt step];
    //[db commitTransaction];
}

#pragma mark Delete operations

/**
  @brief Delete record
*/
- (void)delete
{
    Database *db = [Database instance];

    dbstmt *stmt = [db prepare:@"DELETE FROM DescLRUs WHERE key = ?;"];
    [stmt bindInt:0 val:mPid];
    [stmt step];
}

/**
  @brief Delete all records
*/
+ (void)delete_cond:(NSString *)cond
{
    Database *db = [Database instance];

    if (cond == nil) {
        cond = @"";
    }
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM DescLRUs %@;", cond];
    [db exec:sql];
}

+ (void)delete_all
{
    [DescLRU delete_cond:nil];
}

#pragma mark Internal functions

+ (NSString *)tableName
{
    return @"DescLRUs";
}

@end
