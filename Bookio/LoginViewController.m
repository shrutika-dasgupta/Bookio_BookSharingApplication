//
//  LoginViewController.m
//  Bookio
//
//  Created by Bookio Team on 4/20/14.
//  Copyright (c) 2014 Columbia University. All rights reserved.
//

#import "LoginViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "GetPhoneNoViewController.h"

@interface LoginViewController ()

@end


@implementation LoginViewController
{
    AppDelegate *delegateApp;
    AppDelegate *appDelegateCore;
}
@synthesize managedObjectContext;

- (void)viewDidLoad
{
    [super viewDidLoad];
    //Application Delegate made for passing data across class files
    delegateApp = [[UIApplication sharedApplication]delegate];
    self.managedObjectContext = appDelegateCore.managedObjectContext;
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (screenBounds.size.height == 568)
    {
        // for 4-inch screen
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bookioBgBig.png"]];
    }
    else
    {
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bookioBgSm.png"]];
    }
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -Facebook Login Functions

//ref: https://developers.facebook.com/docs/facebook-login/permissions#reference-basic-info

- (IBAction)LoginButtonClicked:(UIButton *)sender {
   /*
        Creating a session when the user logs in the requests the user for information to be accessd from
        his facebook account
    */
    [FBSession openActiveSessionWithReadPermissions:@[@"basic_info"]
                                       allowLoginUI:YES
                                  completionHandler:
     ^(FBSession *session, FBSessionState state, NSError *error) {

         [self makeRequestForUserData];
         
         // Retrieve the app delegate
         AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
         // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
         [appDelegate sessionStateChanged:session state:state error:error];

     }];
}
/*
    The function that actually requests for the different kinds of data that is to be retrieved from the user.
    Here we request from the user his "basic_info" from which we retrieve "username","first_name","last_name".
 */
- (void) makeRequestForUserData
{
 
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
        
            /*
                If no error is found then a dictionary is created that is used for passing the details of the user to the getPhoneNoView
                using the global object passing functionality with AppDelegate that was initially declared.
             */
            NSString *uid  = [[NSString alloc] init];
            uid = [ result objectForKey:@"username"];
            NSString *ufn = [[NSString alloc] init];
            ufn = [result objectForKey:@"first_name"];
            NSString *uln = [[NSString alloc]init];
            uln = [result objectForKey:@"last_name"];
        
            
            NSMutableDictionary *allUserDetails = [[NSMutableDictionary alloc] init];
            
            [allUserDetails setObject:uid forKey:@"user_id"];
            [allUserDetails setObject:ufn forKey:@"user_fname"];
            [allUserDetails setObject:uln forKey:@"user_lname"];
            
            //The Dictionary  "allUserDetails" is asssigned to the appDelegate object for being shared across the Views.
            delegateApp.userData = allUserDetails;
            
        } else {
            // An error occurred, we need to handle the error
            NSLog(@"error: %@", error.description);
        }
        
    }];

}

@end