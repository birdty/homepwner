//
//  BNRItemCell.m
//  Homepwner
//
//  Created by Tyler Bird on 2/23/16.
//  Copyright (c) 2016 Big Nerd Ranch. All rights reserved.
//

#import "BNRItemCell.h"

@interface BNRItemCell ()

@property (nonatomic, weak) IBOutlet NSLayoutConstraint * imageViewHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint * imageViewWidthConstraint;


@end

@implementation BNRItemCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self updateInterfaceForDynamicTypeSize];
    
    NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self selector:@selector(updateInterfaceForDynamicTypeSize) name:UIContentSizeCategoryDidChangeNotification object:nil];
}

-(void)dealloc
{
    NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(void)updateInterfaceForDynamicTypeSize
{
    UIFont * font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
    self.nameLabel.font = font;
    self.serialNumberLabel.font = font;
    self.valueLabel.font = font;
    
    static NSDictionary * imageSizeDictionary;
    
    if ( ! imageSizeDictionary )
    {
        imageSizeDictionary = @{
            UIContentSizeCategoryExtraSmall : @44,
            UIContentSizeCategorySmall : @44,
            UIContentSizeCategoryMedium : @44,
            UIContentSizeCategoryLarge : @44,
            UIContentSizeCategoryExtraLarge : @49,
            UIContentSizeCategoryExtraExtraLarge : @59,
            UIContentSizeCategoryExtraExtraExtraLarge : @69
        };
    }
    
    NSString * userSize = [[UIApplication sharedApplication] preferredContentSizeCategory];
    
    NSNumber * imageSize = imageSizeDictionary[userSize];

    self.imageViewHeightConstraint.constant = imageSize.floatValue;
    self.imageViewWidthConstraint.constant = imageSize.floatValue;
    
}

-(IBAction)showImage:(id)sender
{
    if ( self.actionBlock )
    {
        self.actionBlock();
    }
}

@end
