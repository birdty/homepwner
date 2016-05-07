//
//  BNRItemStore.m
//  Homepwner
//
//  Created by Tyler Bird on 2/19/16.
//  Copyright (c) 2016 Big Nerd Ranch. All rights reserved.
//

#import "BNRItemStore.h"
#import "BNRItem.h"
#import "BNRImageStore.h"
#import "AppDelegate.h"

@interface BNRItemStore ()

@property (nonatomic) NSMutableArray * privateItems;

@end

@implementation BNRItemStore

+(instancetype)sharedStore
{
    static BNRItemStore * sharedStore;
    
    if ( ! sharedStore )
    {
        sharedStore = [[self alloc] initPrivate];
    }
    
    return sharedStore;
}

-(instancetype)init
{
    [NSException raise:@"Singleton" format:@"Use +[BNRItemStore sharedStore]"];
    return nil;
}

-(instancetype)initPrivate
{
    self = [super init];
    
    if ( self )
    {
        NSString * path = [self itemArchivePath];
        
        _privateItems = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        if ( ! _privateItems )
        {
            _privateItems = [[NSMutableArray alloc] init];
        }
        
    }
    
    return self;
}

-(NSArray *)allItems
{
    return [self.privateItems copy];
}

-(BNRItem *)createItem
{
    BNRItem * item = [[BNRItem alloc] init];
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    
    item.valueInDollars = [defaults integerForKey:BNRNextItemValuePrefsKey];
    item.itemName = [defaults objectForKey:BNRNextItemNamePrefsKey];
    
    [self.privateItems addObject:item];
    
    return item;
}

-(void)removeItem:(BNRItem *)item
{
    NSString * key = item.itemKey;
    
    [[BNRImageStore sharedStore] deleteImageForKey:key];
    
    [self.privateItems removeObjectIdenticalTo:item];
}

-(void)moveItemAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
    if ( fromIndex == toIndex )
    {
        return;
    }
    
    BNRItem * item = self.privateItems[fromIndex];
    
    [self.privateItems removeObjectAtIndex:fromIndex];
    
    [self.privateItems insertObject:item atIndex:toIndex];
}

-(NSString *)itemArchivePath
{
    NSArray * documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString * documentDirectory = [documentDirectories firstObject];
    
    return [documentDirectory stringByAppendingPathComponent:@"items.archive"];
}

-(BOOL)saveChanges
{
    NSString * path = [self itemArchivePath];
    
    return [NSKeyedArchiver archiveRootObject:self.privateItems toFile:path];
}

@end
