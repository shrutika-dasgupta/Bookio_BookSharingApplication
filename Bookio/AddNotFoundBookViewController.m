//
//  AddNotFoundBookViewController.m
//  Bookio
//
//  Created by Bookio Team on 4/27/14.
//  Copyright (c) 2014 Columbia University. All rights reserved.
//

#import "AddNotFoundBookViewController.h"
#import "SWRevealViewController.h"

@implementation AddNotFoundBookViewController

#pragma mark - view load methods

- (void)viewDidLoad
{
    [super viewDidLoad];

    // assign numeric keyboard for the ISBN text feild
    self.isbnText.keyboardType = UIKeyboardTypeNumberPad;
    
    // instanstiate the manangedObjectContext with the one in app delegate
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    //Setting the UI of the AddBook button
    self.addBookButton.layer.borderWidth = 0.5f;
    self.addBookButton.layer.cornerRadius = 5;
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


#pragma mark - Button action methods

-(IBAction)addButtonPressed:(id)sender
{
    NSMutableString *errorMessage = [[NSMutableString alloc] init];
    // Validation of user entered input
    if(self.isbnText.text.length != 13)
    {
        [errorMessage appendString:@"\n- ISBN should be 13 digits long."];
    }
    if(self.bookNameText.text.length == 0)
    {
        [errorMessage appendString:@"\n- Enter a book name."];
    }
    if(self.bookAuthorText.text.length == 0)
    {
        [errorMessage appendString:@"\n- Enter a book author."];
    }
    if(self.courseNoText.text.length == 0)
    {
        [errorMessage appendString:@"\n- Enter a course no. of the book."];
    }
    // show alert if any text filed throws an error
    if(errorMessage.length > 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!!" message:errorMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    else
    {
        // send a request to the admin, asking him to add the book
        
        // encode the entered text as they need to be sent in the URL
        NSString *formattedBookName = [self.bookNameText.text stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        NSString *formattedBookAuthor = [self.bookAuthorText.text stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        NSString *formattedCourseNo = [self.courseNoText.text stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        
        // fetch the current user id
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        [fetchRequest setReturnsObjectsAsFaults:NO];
        NSArray *user = [[NSArray alloc]init];
        user = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
        
        User *userInfo = [user objectAtIndex:0];
        
        // instantiate Bookio Api
        BookioApi *apiCall= [[ BookioApi alloc] init];
        
        // Creates the request url and then calls the method.  The response will be returned in the completion block only.
        // parse it according to the type of query
        NSString *url = [NSString stringWithFormat:@"http://bookio-env.elasticbeanstalk.com/database?query=insertBook&userid=%@&isbn=%@&bookname=%@&bookauthor=%@&courseno=%@", userInfo.user_id,self.isbnText.text,formattedBookName,formattedBookAuthor,formattedCourseNo];
        
        // make the api call by calling the function below which is implemented in the Bookio Api class
        [apiCall urlOfQuery:url queryCompletion:^(NSMutableDictionary *results)
         {
             NSString *value = [results objectForKey:@"status"];
             if([value isEqualToString:@"OK"])
             {
                 // send message to admin
                 if(![MFMessageComposeViewController canSendText]) {
                     UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                     [warningAlert show];
                     return;
                 }
                 
                 NSArray *recipents = @[@"9177050153"];   //Admin phone number
                 
                 // extract user id from core data and pass it in the message so that the user can add the rental for the user
                 NSString *message = [NSString stringWithFormat:@"Hey, My user id is %@ and I request you to add the book:\n ISBN = %@ \n Book Name = %@ \n Book Author = %@ \n Course No. = %@ ",userInfo.user_id, self.isbnText.text, self.bookNameText.text , self.bookAuthorText.text , self.courseNoText.text];
                 
                 MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
                 messageController.messageComposeDelegate = self;
                 [messageController setRecipients:recipents];
                 [messageController setBody:message];
                 
                 // Present message view controller on screen
                 [self presentViewController:messageController animated:YES completion:nil];
                 
             }
             else
             {
                 // if book already exists for some other course, then alert the user with the course no. for which the book already exists.
                 NSString *exists =  [NSString stringWithFormat:@"The book already exists for the course %@",value];
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:exists delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                 [alert show];
                 [alert setTag:5];
             }
         }];
    }
}

// this method is called when 'OK' button on the alert view is pressed
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 5 && buttonIndex == 0)
    {
        // pop the current view controller from the stack
        [self.navigationController popViewControllerAnimated:YES];
    }
}


#pragma mark - Messaging methods
// this method is called when the message is correctly composed
// Ref: http://www.appcoda.com/ios-programming-send-sms-text-message/

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result)
    {
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
    // dismiss the message UI once the message is sent
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // alert the user that the request is sent.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"A request has been sent to the admin. You will receive a message when the book is added." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];
    [alert setTag:5];

}

@end
