//
//  BNRDetailViewController.m
//  Homepwner
//
//  Created by Tyler Bird on 2/19/16.
//  Copyright (c) 2016 Big Nerd Ranch. All rights reserved.
//

#import "BNRDetailViewController.h"
#import "BNRItem.h"
#import "BNRImageStore.h"
#import "BNRItemStore.h"
#import "BNRItem.h"
#import "AppDelegate.h"

@interface BNRDetailViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *valueField;
@property (weak, nonatomic) IBOutlet UITextField *serialNumberField;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cameraButton;

@property (weak, nonatomic) IBOutlet UITextField *valueInput;
@property (weak, nonatomic) IBOutlet UILabel * nameLabel;
@property (weak, nonatomic) IBOutlet UILabel * serialNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel * valueLabel;

@property (strong, nonatomic) UIPopoverController * imagePickerPopover;

@end

@implementation BNRDetailViewController

-(void)updateFonts
{
    UIFont * font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
    self.nameLabel.font = font;
    
    self.serialNumberLabel.font = font;
    
    self.valueLabel.font = font;
    
    self.dateLabel.font = font;
    
    
    self.nameField.font = font;
    
    self.serialNumberField.font = font;
    
    self.valueField.font = font;
    
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.valueField.delegate = self;
    
    UIImageView * iv = [[UIImageView alloc] initWithImage:nil];
    
    iv.contentMode = UIViewContentModeScaleAspectFit;
    
    iv.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:iv];
    
    self.imageView = iv;
    
    NSDictionary * nameMap = @{@"imageView" : self.imageView, @"dateLabel": self.dateLabel, @"toolbar": self.toolbar};
    
    NSArray * horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[imageView]-0-|"
                                                                              options:0 metrics:nil views:nameMap];
    
    NSArray * verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[dateLabel]-[imageView]-[toolbar]" options:0 metrics:nil views:nameMap];
    
    [self.view addConstraints:horizontalConstraints];
    [self.view addConstraints:verticalConstraints];
    
    
    [self.imageView setContentHuggingPriority:200 forAxis:UILayoutConstraintAxisVertical];
    
    [self.imageView setContentCompressionResistancePriority:700 forAxis:UILayoutConstraintAxisVertical];
   
    UIToolbar * numberToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    
    numberToolBar.barStyle = UIBarStyleBlackTranslucent;
    
    NSMutableArray * array = [[NSMutableArray alloc] init];
    
    [array addObject:[[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target: self action:@selector(cancelNumberPad:)]];
 
    [array addObject:[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace  target: nil action:nil]];
    
    [array addObject:[[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target: self action:@selector(doneWithNumberPad:)]];
    
    numberToolBar.items = array;
    
    [numberToolBar sizeToFit];

    [self valueInput].inputAccessoryView = numberToolBar;
}

-(IBAction)cancelNumberPad:(id)sender
{
    [[self valueInput] resignFirstResponder];
    [[self valueInput] setText:@""];
}

-(IBAction)doneWithNumberPad:(id)sender
{
    NSString * numberFromKeyboard = [self valueInput].text;
    [[self valueInput] resignFirstResponder];
}

- (IBAction)backgroundTapped:(id)sender
{
    [self.view endEditing:YES];
}

- (IBAction)removeImage:(id)sender {
    
    self.imageView.image = NULL;
    
    [[BNRImageStore sharedStore] deleteImageForKey:self.item.itemKey];
}

- (IBAction)takePicture:(id)sender
{
    if ( [self.imagePickerPopover isPopoverVisible] )
    {
        [self.imagePickerPopover dismissPopoverAnimated:YES];
        self.imagePickerPopover = nil;
        return;
    }
    
    UIImagePickerController * imagePicker = [[UIImagePickerController alloc] init];
    
    if ( [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else
    {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    [imagePicker setAllowsEditing:YES];
    
    NSArray * nibViews = [[NSBundle mainBundle] loadNibNamed:@"CameraOverlay" owner:self options:nil];
    
    UIView * v = [nibViews objectAtIndex:0];
    
    [imagePicker setCameraOverlayView:v];
    
    imagePicker.delegate = self;
    
    if ( [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad )
    {
        self.imagePickerPopover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
        
        self.imagePickerPopover.delegate = self;
        
        [self.imagePickerPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else
    {
        [self presentViewController:imagePicker animated:YES completion:NULL];
    }
}

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.imagePickerPopover = nil;
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage * image = info[UIImagePickerControllerOriginalImage];
    
    [self.item setThumbnailFromImage:image];
    
    [[BNRImageStore sharedStore] setImage:image forKey:self.item.itemKey];
    
    self.imageView.image = image;
    
    if ( self.imagePickerPopover )
    {
        [self.imagePickerPopover dismissPopoverAnimated:YES];
        self.imagePickerPopover = nil;
    }
    else
    {
    
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIInterfaceOrientation io = [[UIApplication sharedApplication] statusBarOrientation];
    
    [self prepareViewsForOrientation:io];
    
    BNRItem * item = self.item;
    
    self.nameField.text = item.itemName;
 
    self.serialNumberField.text = item.serialNumber;
    
    self.valueField.text = [NSString stringWithFormat:@"%d", item.valueInDollars];
    
    static NSDateFormatter * dateFormatter;
    
    if ( ! dateFormatter )
    {
        dateFormatter = [[NSDateFormatter alloc] init];
        
        dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        
        dateFormatter.timeStyle = NSDateFormatterNoStyle;
        
    }
    
    self.dateLabel.text = [dateFormatter stringFromDate:item.dateCreated];
    
    NSString * itemKey = self.item.itemKey;
    
    UIImage * imageToDisplay = [[BNRImageStore sharedStore] imageForKey:itemKey];
    
    self.imageView.image = imageToDisplay;
    
    [self updateFonts];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.view endEditing:YES];
    
    BNRItem * item = self.item;
    
    item.itemName = self.nameField.text;
    
    item.serialNumber = self.serialNumberField.text;
    
    int newValue = [self.valueField.text intValue];
    
    if ( newValue != item.valueInDollars )
    {
        item.valueInDollars = newValue;
        
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        
        [defaults setInteger:newValue forKey:BNRNextItemValuePrefsKey];
    }
    
    
    
}

-(void)setItem:(BNRItem *)item
{
    _item = item;
    self.navigationItem.title = _item.itemName;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)prepareViewsForOrientation:(UIInterfaceOrientation)orientation
{
    if ( [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad )
    {
        return;
    }
    
    if ( UIInterfaceOrientationIsLandscape(orientation) )
    {
        self.imageView.hidden = YES;
        self.cameraButton.enabled = NO;
    }
    else
    {
        self.imageView.hidden = NO;
        self.cameraButton.enabled = YES;
    }
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self prepareViewsForOrientation:toInterfaceOrientation];
}

-(instancetype)initForNewItem:(BOOL)isNew
{
    self = [super initWithNibName:nil bundle:nil];
    
    if ( self )
    {
        self.restorationIdentifier = NSStringFromClass(self.class);
        
        self.restorationClass = self.class;
        
        if ( isNew )
        {
            UIBarButtonItem * doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(save:)];
            
            self.navigationItem.rightBarButtonItem = doneItem;
            
            UIBarButtonItem * cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
            
            self.navigationItem.leftBarButtonItem = cancelItem;
        }
        
        NSNotificationCenter * defaultCenter = [NSNotificationCenter defaultCenter];
        
        [defaultCenter addObserver:self selector:@selector(updateFonts) name:UIContentSizeCategoryDidChangeNotification object:nil];
        
        
    }
    
    return self;
}

-(void)dealloc
{
    NSNotificationCenter * defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter removeObserver:self];
}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    [NSException raise:@"Wrong initializer" format:@"Use initForNewItem:"];
    return nil;
}

-(void)save:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:self.dismissBlock];
}

-(void)cancel:(id)sender
{
    [[BNRItemStore sharedStore] removeItem:self.item];
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:self.dismissBlock];
}

+(UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)path coder:(NSCoder *)coder
{
    BOOL isNew = NO;
    
    if ( [path count] == 3 )
    {
        isNew = YES;
    }
    
    return [[self alloc] initForNewItem:isNew];
}

-(void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.item.itemKey forKey:@"item.itemKey"];
    
    self.item.itemName = self.nameField.text;
    self.item.serialNumber = self.serialNumberField.text;
    self.item.valueInDollars = [self.valueField.text intValue];
    
    [[BNRItemStore sharedStore] saveChanges];
    
    [super encodeRestorableStateWithCoder:coder];
}

-(void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    NSString * itemKey = [coder decodeObjectForKey:@"item.itemKey"];
    
    for(BNRItem * item in [[BNRItemStore sharedStore] allItems] )
    {
        if ( [itemKey isEqualToString:item.itemKey] )
        {
            self.item = item;
            break;
        }
    }
    
    [super decodeRestorableStateWithCoder:coder];
}

@end
