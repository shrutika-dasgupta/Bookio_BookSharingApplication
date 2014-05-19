//
//  MyAccountViewController.m
//  Bookio
//
//  Created by Bookio Team on 4/21/14.
//  Copyright (c) 2014 Columbia University. All rights reserved.
//

#import "MyAccountViewController.h"
#import "SWRevealViewController.h"

@implementation MyAccountViewController
@synthesize user_phone;
@synthesize user_fname;
@synthesize user_id;
@synthesize user_lname;

-(void) viewDidLoad {
    [super viewDidLoad];
   
}
#pragma mark -Function for setting up the My Account page.
-(void) viewWillAppear:(BOOL)animated{
    
    delegateApp = [[UIApplication sharedApplication]delegate];
    self.managedObjectContext = delegateApp.managedObjectContext;
    
    // Fetch the devices from persistent data store from the 'User' table
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    self.userDetailsPassed = [[NSArray alloc]init];
    self.userDetailsPassed = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
   //Assigning all the values that are retrieved from the Dictionary to the UI labels for display
    User *userInfo = [self.userDetailsPassed objectAtIndex:0];
    
    self.user_fname.text = userInfo.user_fname;
    self.user_lname.text = userInfo.user_lname;
    self.user_id.text = userInfo.user_id;
    self.user_phone.text = userInfo.user_phone;
    
    _sidebarButton.tintColor = [UIColor colorWithWhite:0.00f alpha:0.9f];
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(rightRevealToggle:);
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    [self.tabBarController.tabBar setAlpha:0.0];
    
}

@end
