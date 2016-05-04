//
//  BNRDetailViewController.h
//  Homepwner
//
//  Created by Tyler Bird on 2/19/16.
//  Copyright (c) 2016 Big Nerd Ranch. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BNRItem;

@interface BNRDetailViewController : UIViewController <UITextFieldDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate, UIViewControllerRestoration>

@property (nonatomic, strong) BNRItem * item;

-(instancetype)initForNewItem:(BOOL)isNew;

@property(nonatomic, copy) void(^dismissBlock)(void);

-(IBAction)doneWithNumberPad:(id)sender;
-(IBAction)cancelNumberPad:(id)sender;

@end
