//
//  AddRentedTableViewController.m
//  Bookio
//
//  Created by Bookio Team on 4/30/14.
//  Copyright (c) 2014 Columbia University. All rights reserved.
//

#import "AddRentedTableViewController.h"
#import "AddRentedTableViewCell.h"
#import "UserBooks.h"

@interface AddRentedTableViewController ()

@end

@implementation AddRentedTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) fetchMyBooksDataFromLocalDB {
    //initialize all the arrays
    self.CourseList = [[NSMutableArray alloc] init];
    self.BooksList = [[NSMutableArray alloc] init];
    self.AuthorsList = [[NSMutableArray alloc] init];
    self.ISBNList = [[NSMutableArray alloc] init];
    
    //fetch the user id of the user from user db in core data
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    NSArray *user = [[NSArray alloc]init];
    user = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    User *userInfo = [user objectAtIndex:0];
    
    self.userID = userInfo.user_id;
    
    //fetch books information of books owned by user from the user books db of core data
    fetchRequest = [[NSFetchRequest alloc] init];
    entity = [NSEntityDescription entityForName:@"UserBooks" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    
    NSArray *userBooks = [[NSArray alloc]init];
    userBooks = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    //error if no books
    if([userBooks count] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Alert"
                                  message:@"You don't have any books to rent!!"
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }

    for(UserBooks *userBookEntity in userBooks) {

        NSUInteger courseIndex = [self.CourseList indexOfObject:userBookEntity.courseno];

        if (courseIndex == NSNotFound) {
            //add the course to the cache
            [self.CourseList addObject:userBookEntity.courseno];
            courseIndex = [self.CourseList count] - 1;
            
            //initialize the arrays for this particular course
            [self.BooksList addObject:[[NSMutableArray alloc] init]];
            [self.AuthorsList addObject:[[NSMutableArray alloc] init]];
            [self.ISBNList addObject:[[NSMutableArray alloc] init]];
        }
        //add the book for this course to the cache
        NSMutableArray *courseBooksList = [self.BooksList objectAtIndex:courseIndex];
        [courseBooksList addObject:userBookEntity.name];
        
        //add the authors for this book to the cache
        NSMutableArray *bookAuthorsList = [self.AuthorsList objectAtIndex:courseIndex];
        [bookAuthorsList addObject:userBookEntity.authors];
        
        //add the isbn for this book to the cache
        NSMutableArray *bookISBNList = [self.ISBNList objectAtIndex:courseIndex];
        [bookISBNList addObject:userBookEntity.isbn];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.addRentalView.dataSource = self;
    self.addRentalView.delegate = self;
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    //for resigning keyboard on tap on table view
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:gestureRecognizer];
    [gestureRecognizer setCancelsTouchesInView:NO];
}

- (void) hideKeyboard {
    [self.addRentalView endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //count of courses is the number of sections
    return self.CourseList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //no. of rows in section is the no. of books for the course of that section
    NSMutableArray *courseBooksList = [self.BooksList objectAtIndex:section];
    
    return [courseBooksList count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section

{
    //course no. stored in the array is the title for the section
    return [self.CourseList objectAtIndex:section];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    //beautify the section header instead of using the default one
    UILabel *myLabel = [[UILabel alloc] init];
    myLabel.frame = CGRectMake(5, 2, 320, 20);
    myLabel.font = [UIFont boldSystemFontOfSize:16];
    myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    
    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:myLabel];
    headerView.backgroundColor = [UIColor lightGrayColor];
    
    return headerView;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"myRentalsCell";
    
    AddRentedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if(cell == nil) {
        cell = [[AddRentedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    //display the data for this cell in the UI
    cell.bookName.text = [[self.BooksList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.bookAuthors.text = [[self.AuthorsList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.isbn = [[self.ISBNList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    cell.rentedTo.text = @"";
    cell.tillDate.text = @"";
    
    [cell.addToRentals.layer setBorderWidth:1];
    [cell.addToRentals.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [cell.addToRentals.layer setCornerRadius:5];
    
    cell.clipsToBounds = YES;
    
    cell.delegate = self;
    cell.path = indexPath;
    
    //for numeric keyboard only
    cell.tillDate.keyboardType = UIKeyboardTypeNumberPad;
    
    //disable selection of row
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

-(void) viewWillAppear:(BOOL)animated
{
    //refresh the data displayed on the view
    [self fetchMyBooksDataFromLocalDB];
    [self.tableView reloadData];
    
    //trick for making the cell scroll up when the keyboard appears and then scroll back when it disappears
    [super viewWillAppear:animated];
}

/* Returns true if the string has valid ID */
-(BOOL)hasValidUserId:(NSString *)inputString
{
    NSCharacterSet *validChars = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_."];
    NSCharacterSet *invalidChars = [validChars invertedSet];
    
    NSRange r = [inputString rangeOfCharacterFromSet:invalidChars];
    if ((r.location != NSNotFound) || [inputString length] == 0) {
        NSLog(@"the string contains illegal characters or is empty");
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Alert"
                                  message:@"The user ID is invalid!!"
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
        return NO;
    }
    return YES;
}

/* Returns true if the string has valid date */
-(BOOL)hasValidDate:(NSString *)inputString
{
    NSCharacterSet *validChars = [NSCharacterSet characterSetWithCharactersInString:@"1234567890"];
    NSCharacterSet *invalidChars = [validChars invertedSet];
    
    NSRange r = [inputString rangeOfCharacterFromSet:invalidChars];
    if (r.location != NSNotFound) {
        NSLog(@"the date contains illegal characters");
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Alert"
                                  message:@"The date is invalid!!"
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
        return NO;
    }
    
    //validate date
    if([inputString length] != 0) {
        if([inputString length] != 8) {
            NSLog(@"date is not in format YYYYMMDD");
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@"Alert"
                                      message:@"The date is not in format YYYYMMDD"
                                      delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
            [alertView show];
            return NO;
        }
        //Do proper validation for date
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyyMMdd"];
        NSDate *date = [formatter dateFromString:inputString];
        NSDate *currentDate = [[NSDate alloc] init];
        
        if(date != NULL) {
            NSString *inputDateString = [formatter stringFromDate:date];
            NSString *currentDateString = [formatter stringFromDate:currentDate];
            
            NSComparisonResult dateCompare = [inputDateString compare:currentDateString];
            if ((dateCompare == NSOrderedAscending) || (dateCompare == NSOrderedSame)) {
                NSLog(@"input date is in the past");
                UIAlertView *alertView = [[UIAlertView alloc]
                                          initWithTitle:@"Alert"
                                          message:@"The date is in the past"
                                          delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
                [alertView show];
                return NO;
            }
        } else {
            NSLog(@"date is not correct");
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@"Alert"
                                      message:@"The date is not correct"
                                      delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
            [alertView show];
            return NO;
        }
    } else {
        NSLog(@"date is empty");
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Alert"
                                  message:@"The date is empty!!"
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
        return NO;
    }
    
    return YES;
}

-(void)addRentalButtonPressedAtIndexpath:(NSIndexPath *)indexPath
{
    
    AddRentedTableViewCell *cell = (AddRentedTableViewCell *) [self.addRentalView cellForRowAtIndexPath:indexPath];
    
    if(([self hasValidUserId: cell.rentedTo.text] == YES) && ([self hasValidDate:cell.tillDate.text] == YES)) {
        //add the book to rental database
        BookioApi *apiCall= [[ BookioApi alloc] init];
        
        NSMutableString *formattedDate = [NSMutableString stringWithString: cell.tillDate.text];
        
        [formattedDate insertString:@"-" atIndex:4];
        [formattedDate insertString:@"-" atIndex:7];
        
        
        // just create the needed quest in the url and then call the method as below.. the response will be returned in the block only. parse it accordingly
        NSString *url = [NSString stringWithFormat:@"http://bookio-env.elasticbeanstalk.com/database?query=insertRent&userid=%@&touserid=%@&isbn=%@&enddate=%@",self.userID, cell.rentedTo.text, cell.isbn, formattedDate];
        
        // make the api call by calling the function below which is implemented in the BookioApi class
        [apiCall urlOfQuery:url queryCompletion:^(NSMutableDictionary *results)
         {
             //Verify and delete from core data only when this query succeeds
             NSString *status = [results objectForKey:@"status"];
             if([status isEqualToString:@"OK"])
             {
                 
                 //successfully updated global database,
                 //clear the rent select and sell select from global db of my books for the user
                 NSString  *url = [NSString stringWithFormat:@"http://bookio-env.elasticbeanstalk.com/database?query=updateRent&userid=%@&isbn=%@&rent=0",self.userID, cell.isbn];
                 [apiCall asyncurlOfQuery:url];
                 
                 url = [NSString stringWithFormat:@"http://bookio-env.elasticbeanstalk.com/database?query=updateSell&userid=%@&isbn=%@&sell=0",self.userID, cell.isbn];
                 [apiCall asyncurlOfQuery:url];
                 
                 
                 //now update the user books database in core data            
                 NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                 NSEntityDescription *entity = [NSEntityDescription entityForName:@"UserBooks" inManagedObjectContext:self.managedObjectContext];
                 [fetchRequest setEntity:entity];
                 [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"isbn == %@", cell.isbn]];
                 
                 NSArray *booksToRemove = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
                 
                 for (NSManagedObject *book in booksToRemove) {
                     [self.managedObjectContext deleteObject:book];
                 }
                 
                 NSError *error;
                 if (![self.managedObjectContext save:&error]) {
                     NSLog(@"There was an error in deleting book %@", [error localizedDescription]);
                 }
                 [self fetchMyBooksDataFromLocalDB];
                 [self.tableView reloadData];
             } else {
                 UIAlertView *alertView = [[UIAlertView alloc]
                                           initWithTitle:@"Alert"
                                           message:@"Failed to insert into rented list. Maybe the user id is not valid or there is a connection problem!!"
                                           delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
                 [alertView show];
             }
         }];
    }
}

@end
