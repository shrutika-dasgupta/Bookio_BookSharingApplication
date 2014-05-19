//
//  MyBooksViewController.h
//  Bookio
//
//  Created by Bookio Team on 4/20/14.
//  Copyright (c) 2014 Columbia University. All rights reserved.
//

#import "MyBooksTableViewCell.h"


@interface MyBooksViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
// this button is for the sidebar menu which can dragged in or out from the right side
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@property (strong, nonatomic) IBOutlet UITableView *myBooksTableView;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

//Array which stores the list of courses
@property (strong, nonatomic) NSMutableArray *CourseList;

//These are all 2D-arrays. One dimension contains the course identified by the index in CourseList
// and the other dimension is the data for a particular book.
//List of books for a particular course.
@property (strong, nonatomic) NSMutableArray *BooksList;
//Authors for a particular book.
@property (strong, nonatomic) NSMutableArray *AuthorsList;
//ISBN for a particular book
@property (strong, nonatomic) NSMutableArray *ISBNList;
//Data of a book on whether it is available on rent or not
@property (strong, nonatomic) NSMutableArray *rentSelectList;
//Data of a book on whether it is available for sell or not
@property (strong, nonatomic) NSMutableArray *sellSelectList;
//Price at which book will be rented
@property (strong, nonatomic) NSMutableArray *rentPriceList;
//Price at which the book will be sold
@property (strong, nonatomic) NSMutableArray *sellPriceList;


//Facebook ID of user currently logged in with the app
@property (strong, nonatomic) NSString *userID;

@end
