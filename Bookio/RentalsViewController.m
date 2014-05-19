//
//  RentalsViewController.m
//  Bookio
//
//  Created by Bookio Team on 4/20/14.
//  Copyright (c) 2014 Columbia University. All rights reserved.
//

#import "RentalsViewController.h"
#import "SWRevealViewController.h"
#import "RentalsTableViewCell.h"
#import "UserBooks.h"

@implementation RentalsViewController

int selectedSegment;

-(void) viewDidLoad {
    [super viewDidLoad];
    //default view is rented from
    selectedSegment = 0;
    
    //user cannot add books he has rented from others. He can only add users to whom he has rented books
    //The rented from list gets updated based on other users adding rented to information
    self.addRentalsButton.hidden = YES;
    
    self.rentedFromToTableView.dataSource = self;
    self.rentedFromToTableView.delegate = self;
    
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    //fetch the user id from the core data
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    NSArray *user = [[NSArray alloc]init];
    user = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    User *userInfo = [user objectAtIndex:0];
    
    self.userID = userInfo.user_id;
    
    //initialize the arrays
    self.RentedFromUsers = [[NSMutableArray alloc] init];
    self.RentedToUsers = [[NSMutableArray alloc] init];
}

-(void) viewWillAppear:(BOOL)animated{
    _sidebarButton.tintColor = [UIColor colorWithWhite:0.00f alpha:0.9f];
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(rightRevealToggle:);
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    //reinitialize the arrays
    self.RentedFromUsers = [[NSMutableArray alloc] init];
    self.RentedToUsers = [[NSMutableArray alloc] init];
    
    BookioApi *apiCall= [[ BookioApi alloc] init];
    
    //fetch the rented from information from the global database
    NSString *url = [NSString stringWithFormat:@"http://bookio-env.elasticbeanstalk.com/database?query=getRentedFrom&userid=%@", self.userID];
    
    //we use query which is a blocking one to avoid synchronization issues
    NSMutableDictionary *results = [apiCall asyncurlOfQuery:url];
    NSArray *books = [results objectForKey:@"results"];
    if([books count] != 0)
    {
        for(NSDictionary *eachBook in books)
        {
            [self.RentedFromUsers addObject:eachBook];
        }
    }
    
    //fetch the rented to information from the global database
    url = [NSString stringWithFormat:@"http://bookio-env.elasticbeanstalk.com/database?query=getRentedTo&userid=%@", self.userID];
    
    //we use query which is a blocking one to avoid synchronization issues
    results = [apiCall asyncurlOfQuery:url];
    books = [results objectForKey:@"results"];
    if([books count] != 0)
    {
        for(NSDictionary *eachBook in books)
        {
            [self.RentedToUsers addObject:eachBook];
        }
    }

    //reload the table view after refreshing the information from global database
    [self.rentedFromToTableView reloadData];


}

- (void)tableView:(UITableView *)tableView commitEditingStyle:( UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    RentalsTableViewCell *cell= (RentalsTableViewCell *)[self.rentedFromToTableView cellForRowAtIndexPath:indexPath];
    
    // Check if it's a delete button or edit button...
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        
        // Update the database
        
        BookioApi *apiCall= [[ BookioApi alloc] init];
        
        // just create the needed quest in the url and then call the method as below.. the response will be returned in the block only. parse it accordingly
        
        NSString *url = [NSString stringWithFormat:@"http://bookio-env.elasticbeanstalk.com/database?query=deleteRent&userid=%@&isbn=%@",self.userID, cell.isbn];

        // make the api call by calling the function below which is implemented in the BookioApi class
        [apiCall urlOfQuery:url queryCompletion:^(NSMutableDictionary *results)
         {
             //Verify the query succeeded
             NSString *status = [results objectForKey:@"status"];
             if([status isEqualToString:@"OK"])
             {
                 //TODO: Not a good way to run the query again. See if something better can be done
                 self.RentedToUsers = [[NSMutableArray alloc] init];
                 
                 NSString *url = [NSString stringWithFormat:@"http://bookio-env.elasticbeanstalk.com/database?query=getRentedTo&userid=%@", self.userID];
                 NSMutableDictionary * newResults = [apiCall asyncurlOfQuery:url];
                 NSArray *books = [newResults objectForKey:@"results"];
                 if([books count] != 0)
                 {
                     for(NSDictionary *eachBook in books)
                     {
                         [self.RentedToUsers addObject:eachBook];
                     }
                 }

                 //Add to users books in core data if not already there
                 NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                 NSEntityDescription *entity = [NSEntityDescription entityForName:@"UserBooks" inManagedObjectContext:self.managedObjectContext];
                 [fetchRequest setEntity:entity];
                 [fetchRequest setReturnsObjectsAsFaults:NO];
                 NSArray *userBooks = [[NSArray alloc]init];
                 Boolean found = false;
                 userBooks = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
                 //search for book using isbn
                 for(UserBooks *userBookEntity in userBooks) {
                     if([userBookEntity.isbn isEqualToString:cell.isbn]) {
                         found = true;
                         break;
                     }
                 }
                 if(found == false) {
                     //Add book back to core data UsersBooks if it is not already there
                     UserBooks *addMyBook = [NSEntityDescription insertNewObjectForEntityForName:@"UserBooks"
                                                                          inManagedObjectContext:self.managedObjectContext];
                     addMyBook.user_id = self.userID;
                     addMyBook.isbn = cell.isbn;
                     addMyBook.name = cell.bookName.text;
                     addMyBook.authors = cell.bookAuthors.text;
                     addMyBook.courseno = cell.courseno;
                     addMyBook.rent = [NSNumber numberWithInt:0];
                     addMyBook.rent_cost = [NSNumber numberWithInt:0];
                     addMyBook.sell = [NSNumber numberWithInt:0];
                     addMyBook.sell_cost = [NSNumber numberWithInt:0];
                     
                     NSError *error;
                     // save this insert query, so that the persistant store is updated
                     if (![self.managedObjectContext save:&error]) {
                         NSLog(@"entry not saved to database due to error: %@", [error localizedDescription]);
                         UIAlertView *alertView = [[UIAlertView alloc]
                                                   initWithTitle:@"Alert"
                                                   message:@"There was a problem in updating local cache of My Books database"
                                                   delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
                         [alertView show];
                     }    
                 }
                 //refresh the displayed data after adding the book above
                 [self.rentedFromToTableView reloadData];
             } else {
                 UIAlertView *alertView = [[UIAlertView alloc]
                                           initWithTitle:@"Alert"
                                           message:@"There was a problem in deleting rented book from global database"
                                           delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
                 [alertView show];
             }
         }];
    }
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(selectedSegment == 0)
    {
        //count of rented from users
        return [self.RentedFromUsers count];
    } else if(selectedSegment == 1){
        //count of rented to users
        return [self.RentedToUsers count];
    } else {
        NSLog(@"Incorrect segment value: %d", selectedSegment);
        return 0;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"RentedFromToCell";
    RentalsTableViewCell *cell=(RentalsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        cell = [[RentalsTableViewCell  alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary *eachBook  = NULL;
    
    if(selectedSegment == 0)
    {
        //display books which have been rented from others by the user
        eachBook = [self.RentedFromUsers objectAtIndex:indexPath.row];
        if(eachBook) {
            cell.bookName.text = [eachBook objectForKey:@"book_name"];
            cell.bookAuthors.text = [eachBook objectForKey:@"book_author"];
            cell.userId.text = [NSString stringWithFormat:@"User: %@",[eachBook objectForKey:@"from_user_id"]];
            cell.date.text = [NSString stringWithFormat:@"Till Date: %@", [eachBook objectForKey:@"end_date"]];
            cell.isbn = [NSString stringWithFormat:@"%@", [eachBook objectForKey:@"ISBN"]];
            cell.courseno = [NSString stringWithFormat:@"%@", [eachBook objectForKey:@"course_no"]];
        }
        
    }
    else if (selectedSegment == 1)
    {
        //display books which the user has rented to others
        eachBook = [self.RentedToUsers objectAtIndex:indexPath.row];
        if(eachBook) {
            cell.bookName.text = [eachBook objectForKey:@"book_name"];
            cell.bookAuthors.text = [eachBook objectForKey:@"book_author"];
            cell.userId.text = [NSString stringWithFormat:@"User: %@",[eachBook objectForKey:@"to_user_id"]];
            cell.date.text = [NSString stringWithFormat:@"Till Date: %@", [eachBook objectForKey:@"end_date"]];
            cell.isbn = [NSString stringWithFormat:@"%@", [eachBook objectForKey:@"ISBN"]];
            cell.courseno = [NSString stringWithFormat:@"%@", [eachBook objectForKey:@"course_no"]];
        }
    }
    
    cell.clipsToBounds = YES;
    
    //disable selection of cell
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

- (void) setEditing:(BOOL)editing animated:(BOOL)animated {
    
    [super setEditing:editing animated:animated];
    [self.rentedFromToTableView setEditing:editing animated:animated];
    if (editing == YES) {
        
    } else {
        
    }
}

- (IBAction)rentalSegmentChanged:(id)sender {
    
    UISegmentedControl *seg = sender;
    
    if (seg.selectedSegmentIndex == 0) {
        selectedSegment = 0;
        self.addRentalsButton.hidden = YES;
        self.navigationItem.leftBarButtonItem = nil;
        // Annoying so commenting out
        /*
        if([self.RentedFromUsers count] == 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Information" message:@"You have not rented books from any other user" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }*/
        
    }
    else if (seg.selectedSegmentIndex == 1) {
        selectedSegment = 1;
        self.addRentalsButton.hidden = NO;
        self.navigationItem.leftBarButtonItem = self.editButtonItem;
        // Annoying so commenting out
        /*if([self.RentedToUsers count] == 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Information" message:@"You have not rented books to any one yet" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }*/
    }
    
    [self.rentedFromToTableView reloadData];
}

@end
