//
//  AddRentedTableViewController.h
//  Bookio
//
//  Created by Bookio Team on 4/30/14.
//  Copyright (c) 2014 Columbia University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddRentedTableViewCell.h"

@interface AddRentedTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, AddRentalCellDelegate>
//property for table view
@property (strong, nonatomic) IBOutlet UITableView *addRentalView;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

//Array which stores the list of courses
@property (strong, nonatomic) NSMutableArray *CourseList;

//These are all 2D-arrays. One dimension contains the course identified by the index in CourseList
// and the other dimension is the data for a particular book.
//List of books for a particular course
@property (strong, nonatomic) NSMutableArray *BooksList;
//Authors for a particular book.
@property (strong, nonatomic) NSMutableArray *AuthorsList;
//ISBN for a particular book
@property (strong, nonatomic) NSMutableArray *ISBNList;

//Facebook ID of user currently logged in with the app
@property (strong, nonatomic) NSString *userID;

@end
