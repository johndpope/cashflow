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
{
    NSMutableArray *_categories;
}

-(id)init
{
    self = [super init];
    _categories = nil;

    return self;
}


-(void)reload
{
    _categories = [TCategory find_all:@"ORDER BY sorder"];
}

-(NSInteger)count
{
    return [_categories count];
}

-(TCategory*)categoryAtIndex:(NSInteger)n
{
    ASSERT(mCategories != nil);
    return _categories[n];
}

- (NSInteger)categoryIndexWithKey:(NSInteger)key
{
    NSInteger i, max = [_categories count];
    for (i = 0; i < max; i++) {
        TCategory *c = _categories[i];
        if (c.pid == key) {
            return i;
        }
    }
    return -1;
}

-(NSString*)categoryStringWithKey:(NSInteger)key
{
    NSInteger idx = [self categoryIndexWithKey:key];
    if (idx < 0) {
        return @"";
    }
    TCategory *c = _categories[idx];
    return c.name;
}

-(TCategory*)addCategory:(NSString *)name
{
    TCategory *c = [TCategory new];
    c.name = name;
    [_categories addObject:c];

    [self renumber];

    [c save];
    return c;
}

-(void)updateCategory:(TCategory*)category
{
    [category save];
}

-(void)deleteCategoryAtIndex:(NSInteger)index
{
    TCategory *c = _categories[index];
    [c delete];

    [_categories removeObjectAtIndex:index];
}

- (void)reorderCategory:(NSInteger)from to:(NSInteger)to
{
    TCategory *c = _categories[from];
    [_categories removeObjectAtIndex:from];
    [_categories insertObject:c atIndex:to];
	
    [self renumber];
}

-(void)renumber
{
    NSInteger i, max = [_categories count];

    for (i = 0; i < max; i++) {
        TCategory *c = _categories[i];
        c.sorder = i;
        [c save];
    }
}

@end
