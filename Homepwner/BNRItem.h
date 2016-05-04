//
//  BNRItem.h
//  Quiz
//
//  Created by Tyler Bird on 2/17/16.
//  Copyright (c) 2016 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BNRItem : NSObject <NSCoding>

@property (nonatomic, strong) BNRItem * containedItem;
@property (nonatomic, weak) BNRItem * container;

@property (nonatomic) NSString * itemName;
@property (nonatomic) NSString * serialNumber;
@property (nonatomic) int valueInDollars;
@property (nonatomic, readonly, strong) NSDate * dateCreated;
@property (nonatomic, copy) NSString * itemKey;

@property (strong, nonatomic) UIImage * thumbnail;

-(void)setThumbnailFromImage:(UIImage *)image;


-(instancetype)initWithItemName:(NSString *)name valueInDollars:(int)value serialNumber:(NSString *)sNumber;

-(instancetype)initWithItemname:(NSString *)name;

+(instancetype)randomItem;

@end
