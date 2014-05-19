//
//  SearchViewController.m
//  Bookio
//
//  Created by Bookio Team on 4/20/14.
//  Copyright (c) 2014 Columbia University. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchResultViewController.h"
#import "SWRevealViewController.h"
#import "BookDetailTableViewCell.h"

@implementation SearchViewController

#pragma mark - view loading methods

// this method is called when the view is loaded
-(void) viewDidLoad
{
    [super viewDidLoad];
    
    // sets the border width and corner radius of the search button
    self.SearchButton.layer.borderWidth = 0.5f;
    self.SearchButton.layer.cornerRadius = 5;
    
    // As the datasource will be provided by this view controller
    self.SearchResultsTableView.dataSource=self;
    
    // Any change in the table view must be informed to this view controller
    self.SearchResultsTableView.delegate=self;
    
    // Initially the text box is empty, hence keep the search button disabled.
    [self.SearchButton setEnabled:false];
    
    //for resigning keyboard on tap on table view
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.SearchResultsTableView addGestureRecognizer:gestureRecognizer];
    [gestureRecognizer setCancelsTouchesInView:NO];
}

// This method is called just before the view is going to appear i.e. added to the view hierarchy
-(void) viewWillAppear:(BOOL)animated
{
    _sidebarButton.tintColor = [UIColor colorWithWhite:0.00f alpha:0.9f];
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    _sidebarButton.target = self.revealViewController;
    // right reveal Toggle to allow the side bar menu to slide in from the right side.
    _sidebarButton.action = @selector(rightRevealToggle:);
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    // this viewcontroller will be notified when any changes are made in the search box
    [self.courseNumber setDelegate:self];
    
    
}

// hides keyboard if the user taps anywhere outside the textfield
- (void) hideKeyboard
{
    [self.courseNumber resignFirstResponder];
}


#pragma mark - associated button action methods

- (IBAction)SearchButtonPressed:(UIButton *)sender
{
    // hide keyboards
    [self.courseNumber resignFirstResponder];
    
    NSString *courseno=self.courseNumber.text;
    
    // encode course number as it needs to be passed in the URL
    NSString *formattedCourseNo = [courseno stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    // Load the search table view by requesting the api to return books for the course number just entered
    BookioApi *apiCall= [[ BookioApi alloc] init];
    
    // Creates the needed request as a url and then calls the method. The response will be returned in the completetion block.
    // Parse it according to the query type
    NSString *url = [NSString stringWithFormat:@"http://bookio-env.elasticbeanstalk.com/database?query=getBooksOfCourse&courseno=%@",formattedCourseNo];
    
    // makes the api call by calling the function below which is implemented in the BookioApi class
    [apiCall urlOfQuery:url queryCompletion:^(NSMutableDictionary *results)
     {
         // get the books for this course
         NSArray *books = [results objectForKey:@"results"];
         
         if([books count] == 0)
         {
             // if books not found then show erroe
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry!!" message:@"No Books found for this course." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
             [alert show];
         }
         
        // else popluate the table view
        self.ResultBooks = books;
        [self.SearchResultsTableView reloadData];
     }];
}

// disables the submit button till the textbox is emoty.
- (IBAction)disableSearchButtonTillEmptyString:(id)sender
{
    UITextField *text = (UITextField*)sender;
    if(text.text.length == 0)
    {
        [self.SearchButton setEnabled:false];
    }
    else
    {
        [self.SearchButton setEnabled:true];
    }
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

// fucntion to populate each cell in the table view
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"BookDetails";
    
    // load the custom cell
    BookDetailTableViewCell *cell=(BookDetailTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    // this initializes the cell with the custom table cell created in the class  BookDetailTableViewCell
    if (cell == nil) {
        cell = [[BookDetailTableViewCell  alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    // sets all parameters for rthe current cell
    NSDictionary *eachBook = [self.ResultBooks objectAtIndex:indexPath.row];
    cell.Bname = [eachBook objectForKey:@"book_name"];
    cell.BookName.text = cell.Bname;
    cell.BookAuthor.text = [eachBook objectForKey:@"book_author"];
    cell.isbn = [eachBook objectForKey:@"ISBN"];
    return cell;
}

#pragma mark - segue methods

- (void) prepareForSegue: (UIStoryboardSegue *) segue sender: (id) sender{
    [super prepareForSegue:segue sender:sender];
    // based on the cell clicked get the index no.
    
    NSIndexPath *indexPath = [[self SearchResultsTableView] indexPathForCell:sender];
    // get the cell from the index path so that we hav all information for this corresponding cell
    BookDetailTableViewCell *cell  = (BookDetailTableViewCell *)[self.SearchResultsTableView cellForRowAtIndexPath:indexPath];
    SearchResultViewController *searchResultViewController = [segue destinationViewController];
    
    // passes the isbn and book name to the destination view
    searchResultViewController.isbn=cell.isbn;
    searchResultViewController.book_name = cell.Bname;
}

@end
