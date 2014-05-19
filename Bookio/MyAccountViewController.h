//
//  MyAccountViewController.h
//  Bookio
//
//  Created by Bookio Team on 4/21/14.
//  Copyright (c) 2014 Columbia University. All rights reserved.
//

#import "AppDelegate.h"

@interface MyAccountViewController : UIViewController
{
    AppDelegate *delegateApp;
}

//UI element to set the user_firstName label
@property (strong, nonatomic) IBOutlet UILabel *user_fname;
//UI element to set the user_lastName label
@property (strong, nonatomic) IBOutlet UILabel *user_lname;
//UI element to set the user_id label
@property (strong, nonatomic) IBOutlet UILabel *user_id;
//UI element to set the user_phone number label
@property (strong, nonatomic) IBOutlet UILabel *user_phone;

//UI element for the the swipe side menu bar
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

//property for retrieving information from the core data.
@property (nonatomic,strong)NSArray* userDetailsPassed;

@property (nonatomic,retain) NSManagedObjectContext *managedObjectContext;
@end
