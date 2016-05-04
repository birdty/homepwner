//
//  BNRImageStore.m
//  Homepwner
//
//  Created by Tyler Bird on 2/20/16.
//  Copyright (c) 2016 Big Nerd Ranch. All rights reserved.
//

#import "BNRImageStore.h"

@interface BNRImageStore ()

@property (nonatomic, strong) NSMutableDictionary * dictionary;

@end

@implementation BNRImageStore

+(instancetype)sharedStore
{
    static BNRImageStore * sharedStore;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
    
        sharedStore = [[self alloc] initPrivate];
    
    });
    
    return sharedStore;
}

-(instancetype)init
{
    [NSException raise:@"Singleton" format:@"Use +[BNRImageStore sharedStore]"];
    return nil;
}

-(instancetype)initPrivate
{
    self = [super init];
    
    if ( self )
    {
        _dictionary = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

-(void)setImage:(UIImage *)image forKey:(NSString *)key
{
    
    NSString * imagePath = [self imagePathForKey:key];
    
    NSData * data = UIImageJPEGRepresentation(image, 0.5);
    
    [data writeToFile:imagePath atomically:YES];
}

-(UIImage *)imageForKey:(NSString *)key
{
    UIImage * result = self.dictionary[key];
    
    if ( ! result )
    {
        NSString * imagePath = [self imagePathForKey:key];
        
        result = [UIImage imageWithContentsOfFile:imagePath];
        
        if ( result )
        {
            self.dictionary[key] = result;
        }
        else
        {
            NSLog(@"Error: unable to find %@", imagePath);
        }
    }
    
    return result;
}

-(void)deleteImageForKey:(NSString *)key
{
    if ( ! key ) {
        return;
    }
    
    [self.dictionary removeObjectForKey:key];
    
    NSString * imagePath = [self imagePathForKey:key];
    
    [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
}

-(NSString *)imagePathForKey:(NSString *)key
{
    NSArray * documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString * documentDirectory = [documentDirectories firstObject];
    
    return [documentDirectory stringByAppendingPathComponent:key];
}



@end
