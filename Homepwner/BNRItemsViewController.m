//
//  BNRItemsViewController.m
//  
//
//  Created by Tyler Bird on 2/19/16.
//
//

#import "BNRItemsViewController.h"
#import "BNRDetailViewController.h"
#import "BNRItemStore.h"
#import "BNRItem.h"
#import "BNRItemCell.h"
#import "BNRImageStore.h"
#import "BNRImageViewController.h"

@interface BNRItemsViewController ()

@property (nonatomic, strong) IBOutlet UIView * headerView;

@end

@implementation BNRItemsViewController

-(IBAction)addNewItem:(id)sender
{
    BNRItem * newItem = [[BNRItemStore sharedStore] createItem];
    
    BNRDetailViewController * detailViewController = [[BNRDetailViewController alloc] initForNewItem:YES];
    
    detailViewController.item = newItem;
    
    detailViewController.dismissBlock = ^{
        [self.tableView reloadData];
    };
    
    UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
    
    navController.restorationIdentifier = NSStringFromClass([navController class]);
    
    
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentViewController:navController animated:YES completion:NULL];
}

-(NSString *)modelIdentifierForElementAtIndexPath:(NSIndexPath *)path inView:(UIView *)view
{
    NSString * identifier = nil;
    
    if ( path && view )
    {
        BNRItem * item = [[BNRItemStore sharedStore] allItems][path.row];
        identifier = item.itemKey;
    }
    
    return identifier;
}

-(NSIndexPath *)indexPathForElementWithModelIdentifier:(NSString *)identifier inView:(UIView *)view
{
    NSIndexPath * indexPath = nil;
    
    if ( identifier && view )
    {
        NSArray * items = [[BNRItemStore sharedStore] allItems];
        
        for( BNRItem * item in items )
        {
            if ( [identifier isEqualToString:item.itemKey] )
            {
                int row = [items indexOfObjectIdenticalTo:item];
                indexPath = [NSIndexPath indexPathForRow:row inSection:0];
                break;
            }
        }
    }
    
    return indexPath;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    UINib * nib = [UINib nibWithNibName:@"BNRItemCell" bundle:nil];
    
    [self.tableView registerNib:nib forCellReuseIdentifier:@"BNRItemCell"];
    
    self.tableView.restorationIdentifier = @"BNRItemsViewControllerTableView";
}

-(void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [coder encodeBool:self.isEditing forKey:@"TableViewIsEditing"];
    [super encodeRestorableStateWithCoder:coder];
}

-(void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    self.editing = [coder decodeBoolForKey:@"TableViewIsEditing"];
    
    [super decodeRestorableStateWithCoder:coder];
}

-(instancetype)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    
    if ( self )
    {
        UIImage * image = [UIImage imageNamed:@"mountain.png"];
        
        UIImageView * iv = [[UIImageView alloc] initWithImage:image];
        
        self.tableView.backgroundView = iv;
        
        UINavigationItem * navItem = [self navigationItem];
        
        navItem.title = @"Homepwner";
        
        self.restorationIdentifier = NSStringFromClass(self.class);
        
        self.restorationClass = [self class];
        
        UIBarButtonItem * bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                              target:self action:@selector(addNewItem:)];
        navItem.rightBarButtonItem = bbi;
        
        navItem.leftBarButtonItem = self.editButtonItem;
        
        NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
        
        [nc addObserver:self selector:@selector(updateTableViewForDynamicTypeSize) name:UIContentSizeCategoryDidChangeNotification object:nil];
    }
    
    return self;
}

-(void)dealloc
{
    NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}

-(instancetype)initWithStyle:(UITableViewStyle)style
{
    return [self init];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[BNRItemStore sharedStore] allItems] count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BNRItemCell * cell = [tableView dequeueReusableCellWithIdentifier:@"BNRItemCell" forIndexPath:indexPath];
    
    NSArray * items = [[BNRItemStore sharedStore] allItems];
    
    BNRItem * item = items[indexPath.row];
    
    cell.nameLabel.text = item.itemName;
    
    cell.serialNumberLabel.text = item.serialNumber;
    
    cell.valueLabel.text = [NSString stringWithFormat:@"$%d", item.valueInDollars];
    
    cell.thumbnailView.image = item.thumbnail;
    
    __weak BNRItemCell * weakCell = cell;
    
    cell.actionBlock = ^{
        
        BNRItemCell * strongCell = weakCell;
        
        if ( [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad )
        {
            NSString * itemKey = item.itemKey;
            
            UIImage * img = [[BNRImageStore sharedStore] imageForKey:itemKey];
            
            if ( ! img )
            {
                return;
            }
            
            CGRect rect = [self.view convertRect:strongCell.thumbnailView.bounds fromView:strongCell.thumbnailView];
            
            BNRImageViewController * ivc = [[BNRImageViewController alloc] init];
            
            ivc.image = img;
            
            self.imagePopover = [[UIPopoverController alloc] initWithContentViewController:ivc];
            
            self.imagePopover.delegate = self;
            
            self.imagePopover.popoverContentSize = CGSizeMake(600, 600);
            
            [self.imagePopover presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    };
    
    return cell;
}

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.imagePopover = nil;
}


-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( editingStyle == UITableViewCellEditingStyleDelete )
    {
        NSArray * items = [[BNRItemStore sharedStore] allItems];
        
        BNRItem * item = items[indexPath.row];
        
        [[BNRItemStore sharedStore] removeItem:item];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( indexPath.row == [[[BNRItemStore sharedStore] allItems] count] - 1 )
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [[BNRItemStore sharedStore] moveItemAtIndex:sourceIndexPath.row toIndex:destinationIndexPath.row];
}

-(NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    NSInteger lastIndex = [[[BNRItemStore sharedStore] allItems] count] - 1;
    
    if ( proposedDestinationIndexPath.row == lastIndex )
    {
        return sourceIndexPath;
    }
    else if ( sourceIndexPath.row == lastIndex )
    {
        return sourceIndexPath;
    }
    else
    {
        return proposedDestinationIndexPath;
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Remove";
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BNRDetailViewController * detailViewController = [[BNRDetailViewController alloc] initForNewItem:NO];
    
    NSArray * items = [[BNRItemStore sharedStore] allItems];
    
    BNRItem * selectedItem = items[indexPath.row];
    
    detailViewController.item = selectedItem;
    
    [self.navigationController pushViewController:detailViewController animated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateTableViewForDynamicTypeSize];
}

-(void)updateTableViewForDynamicTypeSize
{
    static NSDictionary * cellHeightDictionary;
    
    if ( ! cellHeightDictionary )
    {
        cellHeightDictionary = @{
            UIContentSizeCategoryExtraSmall : @44,
            UIContentSizeCategorySmall : @44,
            UIContentSizeCategoryMedium : @44,
            UIContentSizeCategoryLarge : @44,
            UIContentSizeCategoryExtraLarge : @55,
            UIContentSizeCategoryExtraExtraLarge : @65,
            UIContentSizeCategoryExtraExtraExtraLarge : @75,
        };
    }
    
    NSString * userSize = [[UIApplication sharedApplication] preferredContentSizeCategory];
    
    NSNumber * cellHeight = cellHeightDictionary[userSize];
    
    [self.tableView setRowHeight:cellHeight.floatValue];
    
    [self.tableView reloadData];
}

+(UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder
{
    return [[self alloc] init];
}

@end

