//
//  RentalsViewController.h
//  Bookio
//
//  Created by Bookio Team on 4/20/14.
//  Copyright (c) 2014 Columbia University. All rights reserved.
//

@interface RentalsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

//table view property
@property (weak, nonatomic) IBOutlet UITableView *rentedFromToTableView;

// this button is for the sidebar menu which can dragged in or out from the right side
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
//property for the add rental button
@property (weak, nonatomic) IBOutlet UIButton *addRentalsButton;

//array holding users to whom books have been rented
@property (nonatomic, strong) NSMutableArray *RentedToUsers;
//array holding books which have been rented from other users
@property (nonatomic, strong) NSMutableArray *RentedFromUsers;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
//Facebook ID of user currently logged in with the app
@property (strong, nonatomic) NSString *userID;
@end
