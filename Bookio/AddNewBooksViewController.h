//
//  AddNewBooksViewController.h
//  Bookio
//
//  Created by Bookio Team on 4/21/14.
//  Copyright (c) 2014 Columbia University. All rights reserved.
//

#import "UserBooks.h"

// This code implements the add New Book view controller i.e. allows the user to add books to his my books
@interface AddNewBooksViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

// this button is used for the sidebar menu
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@property (strong, nonatomic) IBOutlet UITableView *addNewBooksView;

@property (strong, nonatomic) IBOutlet UIButton *searchButton;
@property (strong, nonatomic) IBOutlet UITextField *courseNo;
@property (strong, nonatomic) IBOutlet UIButton *addNewBookButton;
@property (nonatomic, strong) NSArray *ResultBooks;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@end
