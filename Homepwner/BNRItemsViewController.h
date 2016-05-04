//
//  BNRItemsViewController.h
//  
//
//  Created by Tyler Bird on 2/19/16.
//
//

#import <UIKit/UIKit.h>

@interface BNRItemsViewController : UITableViewController <UIPopoverControllerDelegate, UIViewControllerRestoration, UIDataSourceModelAssociation>

@property (strong, nonatomic) UIPopoverController * imagePopover;

@end
