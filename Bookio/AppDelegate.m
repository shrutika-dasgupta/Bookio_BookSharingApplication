//
//  AppDelegate.m
//  Bookio
//
//  Created by Bookio Team on 4/20/14.
//  Copyright (c) 2014 Columbia University. All rights reserved.
//

#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>

@implementation AppDelegate

// sythesize these properties to get their getter and setter methods.
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize userData;


#pragma mark-application state functions

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    // this method is called to remove data from UserBooks table as it gets refreshed everytime the app comes in foreground
    [self removeUserBooks];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    NSArray *user = [[NSArray alloc]init];
    user = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    // This method is called to refresh userbooks table everytime the app becomes active i.e. to update any changes occured while the app was in background
    if([user count]!=0)
    {
        [self updateUserBooks];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background,
    // optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:
    
    // this method is called to remove data from UserBooks table as it gets refreshed everytime the app comes in foreground
    [self removeUserBooks];
}


- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

// this method is called when the application has finished launching
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    UIStoryboard *storyboard =[ UIStoryboard storyboardWithName:@"Main" bundle:nil] ;
    
    // Checks if user is already logged in --> If yes, then directly show the search book screen
    // else show the login view controller
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded || FBSession.activeSession.state == FBSessionStateOpenTokenExtended)
    {
        UITabBarController *SWRevealViewController = [storyboard instantiateViewControllerWithIdentifier:@"SWRevealViewController"];
        
        NSLog(@"Found a cached session");
        
        // If there's one, just open the session silently, without showing the user the login UI
        [FBSession openActiveSessionWithReadPermissions:@[@"basic_info"]
                                           allowLoginUI:NO
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                          // Handler for session state changes
                                          // This method will be called EACH time the session state changes,
                                          // also for intermediate states and NOT just when the session open
                                          [self sessionStateChanged:session state:state error:error];
                                      }];
        
        // load the User Books from central database
        [self updateUserBooks];
        
        // sets the main Search view controller ( tab bar controller as the root view controller )
        [self.window setRootViewController:SWRevealViewController];
        
    }
    else
    {
        
        // user is not logged in, so
        // set loginUIViewController as root view controller
        UIViewController *loginPage = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [[self window] setRootViewController:loginPage];
        
        self.window.backgroundColor = [UIColor whiteColor];
        [self.window makeKeyAndVisible];
        
    }
    // returns yes after all launching options are set
    return YES;
}


#pragma mark-core data methods implementattion

- (NSManagedObjectContext *) managedObjectContext
{
    if (_managedObjectContext != nil)
    {
        return _managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil)
    {
        return _managedObjectModel;
    }
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // URL path for the .sqlite file
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory]
                                               stringByAppendingPathComponent: @"Bookio.sqlite"]];
    NSError *error = nil;
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
    						 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
    						 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                   initWithManagedObjectModel:[self managedObjectModel]];
    if(![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                  configuration:nil URL:storeUrl options:options error:&error]) {
    }
    
    return _persistentStoreCoordinator;
}


#pragma mark-facebook session methods

//Ref: https://developers.facebook.com/docs/facebook-login/ios#permissions

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    if (!error && state == FBSessionStateOpen)
    {
         // If the session was opened successfully
        NSLog(@"Session opened");
        
        // calls the method which redirects the user to the main page
        [self userLoggedIn];
        
        return;
    }
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed)
    {
        // If the session is closed
        NSLog(@"Session closed");
        
        // Show the user the logged-out UI
        [self userLoggedOut];
    }
    
    // Handle errors
    if (error)
    {
        NSLog(@"Error");
        NSString *alertText;
        NSString *alertTitle;
        
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES)
        {
            alertTitle = @"Something went wrong";
            alertText = [FBErrorUtility userMessageForError:error];
            [self showMessage:alertText withTitle:alertTitle];
        }
        else
        {
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled)
            {
                NSLog(@"User cancelled login");
                // Handle session closures that happen outside of the app
            }
            else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession)
            {
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
                [self showMessage:alertText withTitle:alertTitle];
                
                // For simplicity, here we just show a generic message for all other errors
            }
            else
            {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                
                // Show the user an error message
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                [self showMessage:alertText withTitle:alertTitle];
            }
        }
        
        // Clear this token
        [FBSession.activeSession closeAndClearTokenInformation];
        
        // Show the user the logged-out UI
        [self userLoggedOut];
    }
}


// this method is called when the a user's session is closed
- (void)userLoggedOut
{
    UIStoryboard *storyboard =[ UIStoryboard storyboardWithName:@"Main" bundle:nil] ;
    
    // Set loginUIViewController as root view controller
    UIViewController *loginPage = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    [self.window setRootViewController:loginPage];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
}

// Show the user the logged-in UI
- (void)userLoggedIn
{
    
    UIStoryboard *storyboard =[ UIStoryboard storyboardWithName:@"Main" bundle:nil] ;
    UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"GetPhoneNoViewController"];
    // if authentication is successffuly, then take the user to the get phone number view controller
    [self.window setRootViewController:viewController];
}

// Show an alert message
- (void)showMessage:(NSString *)text withTitle:(NSString *)title
{
    [[[UIAlertView alloc] initWithTitle:title
                                message:text
                               delegate:self
                      cancelButtonTitle:@"OK!"
                      otherButtonTitles:nil] show];
}

// During the Facebook login flow, your app passes control to the Facebook iOS app or Facebook in a mobile browser.
// After authentication, your app will be called back with the session information.
// Override application:openURL:sourceApplication:annotation to call the FBsession object that handles the incoming URL
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [FBSession.activeSession handleOpenURL:url];
}

#pragma mark-handle UserBooks in core data

- (void)updateUserBooks
{
    // fetch current userID from core data
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    NSArray *user = [[NSArray alloc]init];
    user = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    User *userInfo = [user objectAtIndex:0];
    
    // Load the user books table by requesting the api to return books owned by the current user
    BookioApi *apiCall= [[ BookioApi alloc] init];
    
    // Creates the needed request as a url and then calls the method. The response will be returned in the completetion block.
    // Parse it according to the query type
    NSString *url = [NSString stringWithFormat:@"http://bookio-env.elasticbeanstalk.com/database?query=getBooksOfUser&userid=%@", userInfo.user_id];
    
    // makes the api call by calling the function below which is implemented in the BookioApi class
    [apiCall urlOfQuery:url queryCompletion:^(NSMutableDictionary *results)
     {
         NSArray *value = [results objectForKey:@"results"];
         
         // if user has atleast one book that he owns
         if([results count] != 0)
         {
             // first clear the userbooks table from coredata, to recover from any inconsistent data after a crash
             [self removeUserBooks];
             
             
             // populate the userbooks table with the books returned by the api
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
                 
                 // save the inserted book
                 NSError *error;
                 if(![self.managedObjectContext save:&error])
                 {
                     NSLog(@"saving error: %@",[error localizedDescription]);
                 }
             }
         }
    }];
}


// clear userBooks table
-(void)removeUserBooks
{
   
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"UserBooks"];
    NSArray *deleteAllArray =[self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    // delete all books in the userBooks table
    for(NSManagedObject *obj in deleteAllArray)
    {
        [self.managedObjectContext deleteObject:obj];
    }
    
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
        return;
    }

}

@end
