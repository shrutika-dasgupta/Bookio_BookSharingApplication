//
//  GetPhoneNoViewController.m
//  Bookio
//
//  Created by Bookio Team on 4/23/14.
//  Copyright (c) 2014 Columbia University. All rights reserved.
//

#import "GetPhoneNoViewController.h"
#import "SWRevealViewController.h"

@interface GetPhoneNoViewController ()

@end

@implementation GetPhoneNoViewController
@synthesize PhoneNumber;
@synthesize SubmitPhoneNumber;
@synthesize managedObjectContext;

NSMutableDictionary *receivedData;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Application delegate initilization and Memory Allocation
    appDelegateCore = [[UIApplication sharedApplication]delegate];
    
    //Assigning the managedObjectContext declared in the application Delegate.
    self.managedObjectContext =appDelegateCore.managedObjectContext;
    
    //Changing the keypad to a number keypad.
    self.PhoneNumber.keyboardType = UIKeyboardTypeNumberPad;
    
    //Setting the UI of the Submit button
    self.SubmitPhoneNumber.layer.borderWidth = 0.5f;
    self.SubmitPhoneNumber.layer.cornerRadius = 5;
    
    // This viewcontroller will be notified when any changes are made in the Phone nUmber Text Field
    [self.PhoneNumber setDelegate:self];
    
    //For resigning keyboard on tap on screen
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:gestureRecognizer];
    [gestureRecognizer setCancelsTouchesInView:NO];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated
{
    //Initailly the submitPhoneNumber Button is disabled when the phone number text field is empty.
    [self.SubmitPhoneNumber setEnabled:false];
    
}
#pragma mark -Phone Number Text box validation.
/*
    Function for hiding the keyboard using the first responder
 */
- (void) hideKeyboard {
    [self.PhoneNumber resignFirstResponder];
}

/*
 keeps the phoneNumber Text field button disabled until soemthing is entered in the search query
 */
- (IBAction)DisableSubmitButtonTillEmptyString:(id)sender
{
    UITextField *phoneNumber = (UITextField*)sender;
    if(phoneNumber.text.length == 0)
    {
        [self.SubmitPhoneNumber setEnabled:false];
    }
    else
    {
        [self.SubmitPhoneNumber setEnabled:true];
    }
}

-(IBAction)screenTapped:(UITapGestureRecognizer *)sender
{
    if (self.PhoneNumber.isFirstResponder) {
        [self.PhoneNumber resignFirstResponder];
    }
}

#pragma mark  -Database updating functions after submit clicked
/*
    The method that is is called when the submit button is clicked.
 */
- (IBAction)SubmitPhoneNumber:(UIButton *)sender {
   
    delegateApp = [[UIApplication sharedApplication] delegate];
    receivedData = [[NSMutableDictionary alloc] init];
    
    // The local dictionary is assigned the user data that is passed via the shared delegate value
    receivedData = delegateApp.userData;
    
    NSString *user_phone = self.PhoneNumber.text;
    
    //the alert box that is called when the length of the string entered in not exactly equal to 10 digits
    if(([self.PhoneNumber.text length] > 10 )|| ([self.PhoneNumber.text length] <10))
    {
        
        [[[UIAlertView alloc] initWithTitle:@"Wrong Input"
                                    message:@"Enter Valid Phone Number."
                                   delegate:self
                          cancelButtonTitle:@"OK!"
                          otherButtonTitles:nil] show];
    
    }
    else
    {
        //Adding a ney key as "user_phone" into the new dictionary.
        [receivedData setObject:user_phone forKey:@"user_phone"];
        
        
        [self.PhoneNumber resignFirstResponder];
        
        // Load the user books table by requesting the api to return books owned by the current user
        BookioApi *apiCall= [[ BookioApi alloc] init];
        
        // Creates the needed request as a url and then calls the method. The response will be returned in the completetion block.
        // Parse it according to the query type
        
        //Here we insert into the Main database the user details like ""username","firstname","lastname","phone number" for the first time user.
        NSString *url = [NSString stringWithFormat:@"http://bookio-env.elasticbeanstalk.com/database?query=insertUser&userid=%@&fname=%@&lname=%@&phone=%@", [receivedData objectForKey:@"user_id"],[receivedData objectForKey:@"user_fname"], [receivedData objectForKey:@"user_lname"], [receivedData objectForKey:@"user_phone"]];
        
        
        [apiCall urlOfQuery:url queryCompletion:^(NSMutableDictionary *results)
         {
             //"results" returns the output of the query that is requested.
             /*
                This results for the key: "status" can take 3 values:
                    "Changed Phone": if the phone number that is entered is different from the one that is present in the database for his given user_id
                                     then the request for changing the phone number to the new one entered is asked using an alert box as confirmation.
                    "User Exists"  : the results are correctedly validated and the user can login
                    "OK"           : for a first time user when entery is made into the database
              */
             NSString *value = [results objectForKey:@"status"];
             if([value isEqualToString:@"Change Phone"])
             {
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Do you want to update your phone number?" message:@"" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"YES", nil];
                 [alert show];
                 
                 //the alert box is given atag for proper identification.
                 [alert setTag:11];
             }
             else if([value isEqualToString:@"User Exists"] || [value isEqualToString:@"OK"])
             {
                 //if no changes are to be made in the database then the "updateLocalData" function is called that updates the information in the core data.
                 [self updateLocalData];
             }
         }];
        
    }
}

/*
    the function that handles the different functionalities that are to be performed when a particular button in the alert box is clicked
 */
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // for the alert box that handles 'phone number updation'.
    if(alertView.tag == 11)
    {
        //When the 'YES' button is clicked
        if(buttonIndex == 1)
        {
            BookioApi *apiCall= [[ BookioApi alloc] init];
            
            //Database query request to update the 'user_phone' value with the new one that is entered in the text box field
            NSString *url = [NSString stringWithFormat:@"http://bookio-env.elasticbeanstalk.com/database?query=updateUserPhone&userid=%@&phone=%@", [receivedData objectForKey:@"user_id"],[receivedData objectForKey:@"user_phone"]];
            
            [apiCall urlOfQuery:url queryCompletion:^(NSMutableDictionary *results)
             {
                 //After proper updatation this function is called for Core data updatation
                 [self updateLocalData];
            }];

        }
        
        //When 'NO' button is clicked
        if(buttonIndex == 0)
        {
            BookioApi *apiCall= [[ BookioApi alloc] init];
            
            //Request for retrieving the entire 'user information' for the particular 'user_id' for updating the core data i.e. the local database.
            NSString *url = [NSString stringWithFormat:@"http://bookio-env.elasticbeanstalk.com/database?query=getMyAccount&userid=%@", [receivedData objectForKey:@"user_id"]];
            
            [apiCall urlOfQuery:url queryCompletion:^(NSMutableDictionary *results)
             {
                 //Retrieving the output obtained from the 'results' that are returned and updating the local database
                 NSArray *result = [results objectForKey:@"results"];
                 NSDictionary *user = [result objectAtIndex:0];
                 NSString *userPhone = [user objectForKey:@"user_phone"];
                 [receivedData setObject:userPhone forKey:@"user_phone"];
                 NSLog(@"%@",[receivedData objectForKey:@"user_phone"]);
                 [self updateLocalData];
             }];
            
        }
       
    }
   
}
/*
    The main function that Updates the local Core database.
    All the local Attributes of 'user_id', 'user_first_name', 'user_last_name', 'user_phone_number' is updated for the local database.
 */

-(void)updateLocalData
{
    
     User *userDetails = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:self.managedObjectContext];
     
     userDetails.user_id= [receivedData objectForKey:@"user_id"];
     userDetails.user_fname= [receivedData objectForKey:@"user_fname"];
     userDetails.user_lname= [receivedData objectForKey:@"user_lname"];
     userDetails.user_phone =[receivedData objectForKey:@"user_phone"];
    
     NSError *error;
     if(![self.managedObjectContext save:&error])
     {
         NSLog(@"saving error: %@",[error localizedDescription]);
     }
        
     UIStoryboard *storyboard =[ UIStoryboard storyboardWithName:@"Main" bundle:nil] ;
     UIViewController *swrevealViewController  = [storyboard instantiateViewControllerWithIdentifier:@"SWRevealViewController"];

    
    // Load the user books table
    BookioApi *apiCall= [[ BookioApi alloc] init];
    
    // Here the request for all the user details about the user with the unique id 'user_id' from the main database is retrieved.
    NSString *url = [NSString stringWithFormat:@"http://bookio-env.elasticbeanstalk.com/database?query=getBooksOfUser&userid=%@", [receivedData objectForKey:@"user_id"]];
    
    //Making the API call
    [apiCall urlOfQuery:url queryCompletion:^(NSMutableDictionary *results)
     {
         NSArray *value = [results objectForKey:@"results"];
         
         // check if retrival is successful
         if([results count] != 0)
         {
             /*
                This part of the code performs the functionality of keeping the database clean before inserting any new information.
                This way the core data stay consistent and no redundant information is left behind.
                Thus the database is completely empty and all values are deleted.
              */
             NSError *error;
             NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"UserBooks"];
             NSArray *deleteAllArray =[self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
             
             for(NSManagedObject *obj in deleteAllArray)
             {
                 [self.managedObjectContext deleteObject:obj];
             }
             
             if (![self.managedObjectContext save:&error]) {
                 NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
                 return;
             }

             /*
                Updating the userbooks table in the core database with required attributes that are returned from the main database for that user with the particular 'user_id'
              */
             for(NSDictionary *book in value)
             {
                 
                 UserBooks *userBooks = [NSEntityDescription insertNewObjectForEntityForName:@"UserBooks" inManagedObjectContext:self.managedObjectContext];
                 
                 userBooks.isbn = [[book objectForKey:@"ISBN"] stringValue];
                 userBooks.rent = [NSNumber numberWithInt:[[book objectForKey:@"rent"] intValue]];
                 userBooks.rent_cost = [NSNumber numberWithInt:[[book objectForKey:@"rent_cost"] intValue]];
                 userBooks.sell = [NSNumber numberWithInt:[[book objectForKey:@"sell"] intValue]];
                 userBooks.sell_cost = [NSNumber numberWithInt:[[book objectForKey:@"sell_cost"] intValue]];
                 userBooks.user_id = [book objectForKey:@"user_id"];
                 
                 userBooks.courseno= [book objectForKey:@"course_no"];
                 userBooks.name = [book objectForKey:@"book_name"];
                 userBooks.authors= [book objectForKey:@"book_author"];
                 
                 NSError *error;
                 if(![self.managedObjectContext save:&error])
                 {
                     NSLog(@"saving error: %@",[error localizedDescription]);
                 }
                 
             }
         }
     }];
    [self presentViewController:swrevealViewController animated:TRUE completion:nil];
    
}



@end
