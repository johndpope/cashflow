#!/usr/bin/ruby

=begin
  O/R Mapper library for iPhone

  Copyright (c) 2010, Takuya Murakami. All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are
  met:

  1. Redistributions of source code must retain the above copyright notice,
  this list of conditions and the following disclaimer. 

  2. Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution. 

  3. Neither the name of the project nor the names of its contributors
  may be used to endorse or promote products derived from this software
  without specific prior written permission. 

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
=end

$LOAD_PATH.push(File.expand_path(File.dirname($0)))

require "schema.rb"

VER = "0.1"
PKEY = "key"

def getObjcType(type)
    case type
    when "INTEGER"
        return "int", "assign"
    when "REAL"
        return "double", "assign"
    when "TEXT"
        return "NSString*", "retain"
    when "DATE"
        return "NSDate*", "retain"
    else
        puts "#{type} is not supported."
        exit 1
    end
end

def getMethodType(type)
    case type
    when "INTEGER"
        return "Int"
    when "REAL"
        return "Double"
    when "TEXT"
        return "String"
    when "DATE"
        return "Date"
    else
        puts "#{type} not supported"
        exit 1
    end
end

# generate header
def generateHeader(cdef, fh)
    fh.puts <<EOF
// Generated by O/R mapper generator ver #{VER}

#import <UIKit/UIKit.h>
#import "ORRecord.h"

@interface #{cdef.bcname} : ORRecord {
EOF

    cdef.members.each do |m|
        type, mem = getObjcType(cdef.types[m])
        fh.puts "    #{type} #{m};"
    end

    fh.puts <<EOF
}

EOF
    
    cdef.members.each do |m|
        type, mem = getObjcType(cdef.types[m])
        fh.puts "@property(nonatomic,#{mem}) #{type} #{m};"
    end

    fh.puts <<EOF

+ (BOOL)migrate;

+ (id)allocator;
+ (NSMutableArray *)find_cond:(NSString *)cond;
+ (dbstmt *)gen_stmt:(NSString *)cond;
+ (NSMutableArray *)find_stmt:(dbstmt *)cond;
+ (#{cdef.bcname} *)find:(int)pid;
- (void)delete;
+ (void)delete_cond:(NSString *)cond;
+ (void)delete_all;

// internal functions
+ (NSString *)tableName;
- (void)insert;
- (void)update;
- (void)_loadRow:(dbstmt *)stmt;

@end
EOF

end

# generate implementation
def generateImplementation(cdef, fh)
    fh.puts <<EOF
// Generated by O/R mapper generator ver #{VER}

#import "Database.h"
#import "#{cdef.bcname}.h"

@implementation #{cdef.bcname}

EOF

    cdef.members.each do |m|
        fh.puts "@synthesize #{m};"
    end
    fh.puts

    fh.puts <<EOF
- (id)init
{
    self = [super init];
    return self;
}

- (void)dealloc
{
EOF
    
    cdef.members.each do |m|
        type, mem = getObjcType(cdef.types[m])
        if (mem == "retain")
            fh.puts "    [#{m} release];"
        end
    end
    
    fh.puts <<EOF
    [super dealloc];
}

/**
  @brief Migrate database table

  @return YES - table was newly created, NO - table already exists
*/

+ (BOOL)migrate
{
    NSArray *columnTypes = [NSArray arrayWithObjects:
EOF

    cdef.members.each do |m|
        fh.puts "        @\"#{m}\", @\"#{cdef.types[m]}\","
    end

    fh.puts <<EOF
        nil];

    return [super migrate:columnTypes];
}

/**
  @brief allocate entry
*/
+ (id)allocator
{
    id e = [[#{cdef.bcname} alloc] init];
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
        sql = @"SELECT * FROM #{cdef.name};";
    } else {
        sql = [NSString stringWithFormat:@"SELECT * FROM #{cdef.name} %@;", cond];
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
        #{cdef.bcname} *e = [[self allocator] autorelease];
        [e _loadRow:stmt];
        [array addObject:e];
    }
    return array;
}

/**
  @brief get the record matchs the id

  @param pid Primary key of the record
  @return record
*/
+ (#{cdef.bcname} *)find:(int)pid
{
    Database *db = [Database instance];

    dbstmt *stmt = [db prepare:@"SELECT * FROM #{cdef.name} WHERE #{PKEY} = ?;"];
    [stmt bindInt:0 val:pid];
    if ([stmt step] != SQLITE_ROW) {
        return nil;
    }

    #{cdef.bcname} *e = [[self allocator] autorelease];
    [e _loadRow:stmt];
 
    return e;
}

- (void)_loadRow:(dbstmt *)stmt
{
    self.pid = [stmt colInt:0];
EOF

    i = 1
    cdef.members.each do |m|
        type = cdef.types[m]
        method = "col" + getMethodType(type)
        fh.puts "    self.#{m} = [stmt #{method}:#{i}];"
        i += 1
    end
    
    fh.puts <<EOF

    isInserted = YES;
}

+ (NSString *)tableName
{
    return @"#{cdef.name}";
}

- (void)insert
{
    [super insert];

    Database *db = [Database instance];
    dbstmt *stmt;
    
    [db beginTransaction];
EOF

    fh.print "    stmt = [db prepare:@\"INSERT INTO #{cdef.name} VALUES(NULL"
    cdef.members.each do |m|
        fh.print ",?"
    end
    fh.print ");\"];\n"
    fh.puts

    i = 0
    cdef.members.each do |m|
        method = "bind" + getMethodType(cdef.types[m])
        fh.puts "    [stmt #{method}:#{i} val:#{m}];"
        i += 1
    end

    fh.puts <<EOF
    [stmt step];

    self.pid = [db lastInsertRowId];

    [db commitTransaction];
    isInserted = YES;
}

- (void)update
{
    [super update];

    Database *db = [Database instance];
    [db beginTransaction];

    dbstmt *stmt = [db prepare:@"UPDATE #{cdef.name} SET "
EOF

    isFirst = true
    cdef.members.each do |m|
        fh.print "        \""
        if (isFirst)
            isFirst = false
        else
            fh.print ","
        end
        fh.puts "#{m} = ?\""
    end
    
    fh.puts "        \" WHERE #{PKEY} = ?;\"];"

    i = 0
    cdef.members.each do |m|
        method = "bind" + getMethodType(cdef.types[m])
        fh.puts "    [stmt #{method}:#{i} val:#{m}];"
        i += 1
    end
    fh.puts <<EOF
    [stmt bindInt:#{i} val:pid];

    [stmt step];
    [db commitTransaction];
}

/**
  @brief Delete record
*/
- (void)delete
{
    Database *db = [Database instance];

    dbstmt *stmt = [db prepare:@"DELETE FROM #{cdef.name} WHERE #{PKEY} = ?;"];
    [stmt bindInt:0 val:pid];
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
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM #{cdef.name} %@;", cond];
    [db exec:sql];
}

+ (void)delete_all
{
    [#{cdef.bcname} delete_cond:nil];
}

@end
EOF

end

# start from here
if (ARGV.size != 1)
    STDERR.puts "usage: #{$0} [deffile]"
    exit 1
end

schema = Schema.new
schema.loadFromFile(ARGV[0])
#schema.dump

# generate
schema.defs.each do |cdef|
    STDERR.puts "generate #{cdef.bcname}.h"
    fh = open(cdef.bcname + ".h", "w")
    generateHeader(cdef, fh)
    fh.close

    STDERR.puts "generate #{cdef.bcname}.m"
    fh = open(cdef.bcname + ".m", "w")
    generateImplementation(cdef, fh)
    fh.close
end