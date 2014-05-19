//
//  SearchResultViewController.m
//  Bookio
//
//  Created by Boookio Team on 4/22/14.
//  Copyright (c) 2014 Columbia University. All rights reserved.
//

#import "SearchResultViewController.h"
#import "SWRevealViewController.h"
#import "RentOrBuyTableViewCell.h"

// this variable indicates as to which view is selected from the segmented control bar
int selectedView;

#pragma mark - View related methods

@implementation SearchResultViewController

// This method is called when the view is loaded
-(void) viewDidLoad
{
    
    [super viewDidLoad];
    
    //set initial selected view to rent segment
    selectedView = 0;
    
    // Any change in the table view must be informed to this view controller
    self.RentOrBuyTableView.delegate=self;
    
    // As the datasource will be provided by this view controller
    self.RentOrBuyTableView.dataSource=self;
    
    // instanstiate the manangedObjectContext with the one in app delegate
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    // get the current logged in user's info
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    NSArray *user = [[NSArray alloc]init];
    user = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    User *userInfo = [user objectAtIndex:0];
    
    self.myUserID = userInfo.user_id;

    
}

// This method is called just before the view is going to appear i.e. added to the view hierarchy
-(void) viewWillAppear:(BOOL)animated
{
    self.RentUsers = [[NSMutableArray alloc] init];
    self.BuyUsers = [[NSMutableArray alloc] init];
    
    AppDelegate *delegateApp = [[UIApplication sharedApplication]delegate];
    self.managedObjectContext = delegateApp.managedObjectContext;
    
    _sidebarButton.tintColor = [UIColor colorWithWhite:0.00f alpha:0.9f];
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(rightRevealToggle:);
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    // get the isbn of the book passed by the searchViewController using a segue
    NSString *isbn = [self.isbn description];
    
    // initialize the BookioApi
    BookioApi *apiCall= [[ BookioApi alloc] init];
    
    // Create the needed url request, the response will be returned in the completetion block only
    // parse it according to the query type
    NSString *url = [NSString stringWithFormat:@"http://bookio-env.elasticbeanstalk.com/database?query=getRentAndSellDetails&isbn=%@",isbn];

    // make the api call by calling the function below which is implemented in the BookioApi class
    [apiCall urlOfQuery:url queryCompletion:^(NSMutableDictionary *results)
    {
         NSArray *users = [results objectForKey:@"results"];
        
         // there is atleast one user ready to rent or sell the book
         if([users count] != 0)
         {
             for(NSDictionary *eachUser in users)
             {
                 // the userid of the user ready to rent/sell this book
                 NSString *bookUserId = [eachUser objectForKey:@"user_id"];
                 
                 // if a user is renting this book, then all all his details in the RentUsers array
                 if([[eachUser objectForKey:@"rent"] intValue] == 1)
                 {
                     // Do not show books the user owns
                     if([bookUserId isEqualToString:self.myUserID] != YES)
                     {
                         [self.RentUsers addObject:eachUser];
                     }
                 }
                 // if a user is selling this book, then all all his details in the BuyUsers array
                 if([[eachUser objectForKey:@"sell"] intValue] == 1)
                 {
                     //Do not show books that the user owns
                     if([bookUserId isEqualToString:self.myUserID] != YES)
                     {
                         [self.BuyUsers addObject:eachUser];
                     }
                 }
             }
             // reload the data in table view
             [self.RentOrBuyTableView reloadData];
         }
        
         // if no user is renting this book then, give an alert indicating this
         if([self.RentUsers count] == 0)
         {
            
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry!!" message:@"No User is renting this book." delegate: self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
             [alert show];
         }
    }];

}

#pragma mark - Segment control methods
// keeps track of the current selected segment
- (IBAction)SegmentChanged:(id)sender
{
    
    UISegmentedControl *seg = sender;
    // the Rent segment is selected
    if (seg.selectedSegmentIndex == 0)
    {
        selectedView = 0;
        [self.RentOrBuyTableView reloadData];
        
        if([self.RentUsers count] == 0)
        {
            // if no user is renting this book then, give an alert indicating this
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry!!" message:@"No User is renting this book." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    // the buy segment is selected
    else if (seg.selectedSegmentIndex == 1)
    {
        selectedView = 1;
        [self.RentOrBuyTableView reloadData];

        // if no user is selling this book then, give an alert indicating this
        if([self.BuyUsers count] == 0)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry!!" message:@"No User is selling this book." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];

        }
    }
}


#pragma mark - Table view related methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // returns the number of rows in a section based on whether rentUsers need to be displayed or BuyUsers
    if(selectedView == 0)
    {
        return [self.RentUsers count];
    }
    return [self.BuyUsers count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // custom cell
    static NSString *cellIdentifier = @"RentBuyCell";
    RentOrBuyTableViewCell *cell=(RentOrBuyTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if (cell == nil)
    {
        cell = [[RentOrBuyTableViewCell  alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    // rent view is selected
    if(selectedView == 0)
    {
        NSDictionary *eachUser = [self.RentUsers objectAtIndex:indexPath.row];
        cell.UserId.text = [eachUser objectForKey:@"user_id"];
        cell.Cost.text = [NSString stringWithFormat:@"%@$",[[eachUser objectForKey:@"rent_cost"] stringValue]];
        cell.phoneNumber = [eachUser objectForKey:@"user_phone"];
    }
    // buy view is selected
    else if (selectedView == 1)
    {
  
        NSDictionary *eachUser = [self.BuyUsers objectAtIndex:indexPath.row];
        cell.UserId.text = [eachUser objectForKey:@"user_id"];
        cell.Cost.text = [NSString stringWithFormat:@"%@$",[[eachUser objectForKey:@"sell_cost"] stringValue]];
        cell.phoneNumber = [eachUser objectForKey:@"user_phone"];
    }
    
    return cell;
}

// the button is pressed to either send a message to the user for either renting/buying the book
- (IBAction)SendMessageButtonPressed:(UIButton *)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.RentOrBuyTableView];
    NSIndexPath *indexPath = [[self RentOrBuyTableView] indexPathForRowAtPoint:buttonPosition];
    
    // get the cell from the index path so that we hav all information for this corresponding cell
    RentOrBuyTableViewCell *cell  = (RentOrBuyTableViewCell *)[self.RentOrBuyTableView cellForRowAtIndexPath:indexPath];
    
    NSString *status;
    
    if(selectedView == 0)
    {
        status = @"renting";
    }
    else if (selectedView == 1)
    {
        status = @"buying";
    }
    
    // this alert is displayed in case the device does not support text messaging.
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    
    // set the recipients phone number i.e. the phone number to view message needs to be sent.
    NSArray *recipents = @[cell.phoneNumber];
    
    // Fetch the current user from persistent data store
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    NSArray *user = [[NSArray alloc]init];
    user = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    

    User *userInfo = [user objectAtIndex:0];
    
    // pass the extracted userid in the message so that the user can add the rental for the user
    NSString *message = [NSString stringWithFormat:@"Hey, My user id is %@ and I am interested in %@ the %@ book",userInfo.user_id,status, [self.book_name description]];
    
    // initialize the message controller
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:recipents];
    [messageController setBody:message];
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
    
}

#pragma mark - SMS related methods

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    
    // dismiss message view controller once the message is sent.
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
