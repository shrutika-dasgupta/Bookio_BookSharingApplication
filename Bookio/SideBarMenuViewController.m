//
//  SideBarMenuViewController.m
//  Bookio
//
//  Created by Bookio Team on 4/20/14.
//  Copyright (c) 2014 Columbia University. All rights reserved.
//

#import "SideBarMenuViewController.h"
#import "SWRevealViewController.h"
#import <FacebookSDK/FacebookSDK.h>

// Reference: http://www.appcoda.com/ios-programming-sidebar-navigation-menu/
// The SWRevealView api is used to implement the side bar menu functionality. The source code can be found in the Library folder.

@interface SideBarMenuViewController()

// array of items displayed in the side-bar menu
@property (nonatomic, strong) NSArray *menuItems;

@end

@implementation SideBarMenuViewController

// to get the getter and setter method of the managedObjectContext
@synthesize managedObjectContext;

#pragma mark - Initialization

// initialized the table view style
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

# pragma mark - view loading methods

// this method is called when the view is loaded
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // default rows get initialized with these cell identifiers
    _menuItems = @[@"Title",@"Home", @"MyAccount", @"AddNewBooks", @"Logout"];
    
}

// this view is loaded when the view is about to appear
-(void)viewWillAppear:(BOOL)animated
{
    // instanstiate the manangedObjectContext with the one in app delegate

    appDelegate = [[UIApplication sharedApplication]delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
}

#pragma mark - Table view related methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.menuItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [self.menuItems objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    return cell;
}

// this method is called when a row is selected in the side-menu
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [self.menuItems objectAtIndex:indexPath.row];
   
    // runs the below code only when the 'Logout' cell is clicked
    if( [CellIdentifier isEqualToString:@"Logout"])
    {
        // If the session state is any of the two "open" states when the button is clicked
        if (FBSession.activeSession.state == FBSessionStateOpen || FBSession.activeSession.state == FBSessionStateOpenTokenExtended)
        {
            // Close the session and remove the access token from the cache
            // The session state handler (in the app delegate) will be called automatically
            [FBSession.activeSession closeAndClearTokenInformation];
            
            
            // delete user details from the User Table
            NSError *error;
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"User"];
            NSArray *deleteAllArray =[self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
          
            for(NSManagedObject *obj in deleteAllArray)
            {
                [self.managedObjectContext deleteObject:obj];
            }
            
            fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"UserBooks"];
            deleteAllArray =[self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            
            // delete existing books in the userBooks table
            for(NSManagedObject *obj in deleteAllArray)
            {
                [self.managedObjectContext deleteObject:obj];
            }

            // save the deletion changes
            if (![self.managedObjectContext save:&error]) {
                NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
                return;
            }
           
        }
    }
}

#pragma mark - segue methods

- (void) prepareForSegue: (UIStoryboardSegue *) segue sender: (id) sender
{
    [super prepareForSegue:segue sender:sender];
    
    // Set the title of navigation bar by using the menu items
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    
    UINavigationController *destViewController = (UINavigationController*)segue.destinationViewController;
    destViewController.title = [[_menuItems objectAtIndex:indexPath.row] capitalizedString];
 
    // SWRevealViewControllerSegue is a custom segue provided in the SWRevealView api. It helps to change views when the sidebar menu is shown/hidden
    if ( [segue isKindOfClass: [SWRevealViewControllerSegue class]] )
    {
        SWRevealViewControllerSegue *swSegue = (SWRevealViewControllerSegue*) segue;
        
        // show the front view controller
        swSegue.performBlock = ^(SWRevealViewControllerSegue* rvc_segue, UIViewController* svc, UIViewController* dvc)
        {
            
            UINavigationController* navController = (UINavigationController*)self.revealViewController.frontViewController;
            if([[segue identifier] isEqualToString:@"showBookio"] )
            {
                [self.revealViewController pushFrontViewController:dvc animated:YES];
            }
            else
            {
                [navController setViewControllers: @[dvc] animated: NO ];
                [self.revealViewController setFrontViewPosition: FrontViewPositionLeft animated: YES];
            }
        };
    }

}

@end
