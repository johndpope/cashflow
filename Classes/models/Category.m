// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "Category.h"
#import "AppDelegate.h"

@implementation TCategory

@end

@implementation Categories

-(id)init
{
    self = [super init];
    mCategories = nil;

    return self;
}


-(void)reload
{
    mCategories = [TCategory find_all:@"ORDER BY sorder"];
}

-(int)count
{
    return [mCategories count];
}

-(TCategory*)categoryAtIndex:(int)n
{
    ASSERT(mCategories != nil);
    return [mCategories objectAtIndex:n];
}

- (int)categoryIndexWithKey:(int)key
{
    int i, max = [mCategories count];
    for (i = 0; i < max; i++) {
        TCategory *c = [mCategories objectAtIndex:i];
        if (c.pid == key) {
            return i;
        }
    }
    return -1;
}

-(NSString*)categoryStringWithKey:(int)key
{
    int idx = [self categoryIndexWithKey:key];
    if (idx < 0) {
        return @"";
    }
    TCategory *c = [mCategories objectAtIndex:idx];
    return c.name;
}

-(TCategory*)addCategory:(NSString *)name
{
    TCategory *c = [[TCategory alloc] init];
    c.name = name;
    [mCategories addObject:c];

    [self renumber];

    [c save];
    return c;
}

-(void)updateCategory:(TCategory*)category
{
    [category save];
}

-(void)deleteCategoryAtIndex:(int)index
{
    TCategory *c = [mCategories objectAtIndex:index];
    [c delete];

    [mCategories removeObjectAtIndex:index];
}

- (void)reorderCategory:(int)from to:(int)to
{
    TCategory *c = [mCategories objectAtIndex:from];
    [mCategories removeObjectAtIndex:from];
    [mCategories insertObject:c atIndex:to];
	
    [self renumber];
}

-(void)renumber
{
    int i, max = [mCategories count];

    for (i = 0; i < max; i++) {
        TCategory *c = [mCategories objectAtIndex:i];
        c.sorder = i;
        [c save];
    }
}

@end
