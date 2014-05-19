//
//  AddNewBooksViewController.m
//  Bookio
//
//  Created by Bookio Team on 4/21/14.
//  Copyright (c) 2014 Columbia University. All rights reserved.
//

#import "AddNewBooksViewController.h"
#import "SWRevealViewController.h"
#import "AddNewBooksTableViewCell.h"

NSString *courseno;

@implementation AddNewBooksViewController

#pragma mark - view loading methods

-(void) viewDidLoad
{
    [super viewDidLoad];

    // Set UI properties of the search button
    self.searchButton.layer.borderWidth = 0.5f;
    self.searchButton.layer.cornerRadius = 5;
    
    // As the datasource will be provided by this view controller
    self.addNewBooksView.dataSource=self;
    // Any change in the table view must be informed to this view controller
    self.addNewBooksView.delegate=self;
    
    // Initially the search button is kept disabled as text field is empty
    [self.searchButton setEnabled:false];
    
    // this view controller will be notified when anything is entered in the text field
    [self.courseNo setDelegate:self];
    
    // instanstiate the manangedObjectContext with the one in app delegate
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    //for resigning keyboard on tap on table view
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.addNewBooksView addGestureRecognizer:gestureRecognizer];
}


-(void) viewWillAppear:(BOOL)animated{
    _sidebarButton.tintColor = [UIColor colorWithWhite:0.00f alpha:0.9f];
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(rightRevealToggle:);
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    [self.tabBarController.tabBar setAlpha:0.0];

}

#pragma mark - Button Action methods

// hides the keyboard
- (void) hideKeyboard {
    [self.courseNo resignFirstResponder];
}

// this method disables/enables the search button depending on whether the text field is empty or not empty
- (IBAction)disableSearchButtonTillEmptyString:(id)sender
{
    UITextField *text = (UITextField*)sender;
    if(text.text.length == 0)
    {
        [self.searchButton setEnabled:false];
    }
    else
    {
        [self.searchButton setEnabled:true];
    }
}

// This method is called when the search button is pressed
- (IBAction)SearchButtonPressed:(UIButton *)sender {
    
    [self.courseNo resignFirstResponder];
    courseno=self.courseNo.text;
    
    //encode the course number so that it can be passed in the URL
    NSString *formattedCourseNo = [courseno stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    // instantiate Bookio Api
    BookioApi *apiCall= [[ BookioApi alloc] init];
    
    // Creates the request url and then calls the method.  The response will be returned in the completion block only.
    // parse it according to the type of query
    NSString *url = [NSString stringWithFormat:@"http://bookio-env.elasticbeanstalk.com/database?query=getBooksOfCourse&courseno=%@",formattedCourseNo];
    
    // make the api call by calling the function below which is implemented in the BookioApi class
    [apiCall urlOfQuery:url queryCompletion:^(NSMutableDictionary *results)
     {
         NSArray *books = [results objectForKey:@"results"];
         // checks if any books are returned for that particular course
         if([books count] == 0)
         {
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry!!" message:@"No Books found for this course." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
             [alert show];
         }
         
         self.ResultBooks = books;
         
         // reload the table view with new data
         [self.addNewBooksView reloadData];
     }];
}


// Checks if the user has already added the book to his my books
-(void)checkAddButtonStatus:(id)sender
{
    // recogize the location fo the button pressed
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.addNewBooksView];
    
    // based on the co-ordinates find the row for which the fav button was pressed
    NSIndexPath *indexPath = [self.addNewBooksView indexPathForRowAtPoint:buttonPosition];
    
    // get the cell from the index path so that we hav all information for this corresponding cell
    AddNewBooksTableViewCell *cell  = (AddNewBooksTableViewCell *)[self.addNewBooksView cellForRowAtIndexPath:indexPath];
    
    // get the userid of the current user
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    NSArray *user = [[NSArray alloc]init];
    user = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    User *userInfo = [user objectAtIndex:0];
    
    // instantiate Bookio Api
    BookioApi *apiCall= [[BookioApi alloc] init];
    
    // create a request URL to insert the book into user's my book
    NSString *url = [NSString stringWithFormat:@"http://bookio-env.elasticbeanstalk.com/database?query=insertMyBook&userid=%@&isbn=%@", userInfo.user_id, cell.isbn];
    
    // make the api call by calling the function below which is implemented in the BookioApi class
    [apiCall urlOfQuery:url queryCompletion:^(NSMutableDictionary *results)
     {
         //Verify the query succeeded
         NSString *status = [results objectForKey:@"status"];
         
         if([status isEqualToString:@"OK"])
         {
             UserBooks *addMyBook = [NSEntityDescription insertNewObjectForEntityForName:@"UserBooks"
                                                                  inManagedObjectContext:self.managedObjectContext];
             addMyBook.user_id = userInfo.user_id;
             addMyBook.isbn = cell.isbn;
             addMyBook.name = cell.bookName.text;
             addMyBook.authors = cell.bookAuthor.text;
             addMyBook.courseno = courseno;
             addMyBook.rent = [NSNumber numberWithInt:0];
             addMyBook.rent_cost = [NSNumber numberWithInt:0];
             addMyBook.sell = [NSNumber numberWithInt:0];
             addMyBook.sell_cost = [NSNumber numberWithInt:0];
             
             NSError *error;
             
             // save this insert query, so that the persistant store is updated
             if (![self.managedObjectContext save:&error])
             {
                 NSLog(@"entry not saved to database due to error: %@", [error localizedDescription]);
             }
             [cell.addButton setEnabled:NO];
         }
         else if([status isEqualToString:@"exists"])
         {
             UIAlertView *alertView = [[UIAlertView alloc]
                                       initWithTitle:@"Alert"
                                       message:@"The book is already present in your list. Maybe you have rented it."
                                       delegate:nil
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
             [alertView show];
         }
         else
         {
             UIAlertView *alertView = [[UIAlertView alloc]
                                       initWithTitle:@"Alert"
                                       message:@"Failed to update global My Books database."
                                       delegate:nil
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
             [alertView show];
         }
     }];
}

#pragma mark - Table view related methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // Return the number of rows in the section.
    return [self.ResultBooks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"Books";
    
    AddNewBooksTableViewCell *cell=(AddNewBooksTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    // this initializes the cell with the custom table cell created in the class AddNewBooksTableViewCell
    if (cell == nil)
    {
        cell = [[AddNewBooksTableViewCell  alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary *eachBook = [self.ResultBooks objectAtIndex:indexPath.row];
    
    cell.bookName.text = [eachBook objectForKey:@"book_name"];
    cell.bookAuthor.text = [eachBook objectForKey:@"book_author"];
    cell.isbn = [[eachBook objectForKey:@"ISBN"] stringValue];
    [cell.addButton setEnabled:YES];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"UserBooks" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    
    NSArray *userBooks = [[NSArray alloc]init];
    userBooks = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    // if book is already in my books, then the add button is disabled else its enabled
    for(UserBooks *userBookEntity in userBooks) {
        if([cell.isbn isEqualToString:userBookEntity.isbn]) {
            [cell.addButton setEnabled:NO];
            break;
        }
    }
    
    [cell.addButton addTarget:self action:@selector(checkAddButtonStatus:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

@end
