//
//  BNRImageStore.h
//  Homepwner
//
//  Created by Tyler Bird on 2/20/16.
//  Copyright (c) 2016 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BNRImageStore : NSObject

+(instancetype)sharedStore;

-(void)setImage:(UIImage *)image forKey:(NSString *)key;

-(UIImage *)imageForKey:(NSString *)key;

-(void)deleteImageForKey:(NSString *)key;


@end
