//
//  AppDelegate.h
//  Bookio
//
//  Created by Bookio Team on 4/20/14.
//  Copyright (c) 2014 Columbia University. All rights reserved.
//

#import "LoginViewController.h"
#import "User.h"
#import "UserBooks.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

// Reference : http://www.codigator.com/tutorials/ios-core-data-tutorial-with-example/
// the 3 variable declared below are declared to be used by core data

// This model gives the models for all entities in the database
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;

// This acts as a temporary space in which the data can be altered before actaully updating the modification in the persistent store
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

// This property co-ordinates between the context and the underlying sqlite database(persitent storage)
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator ;

//This variable identifies the current window
@property (nonatomic, strong) UIWindow *window;

//Global variable used to pass data between view controllers
@property (nonatomic, retain) NSMutableDictionary *userData;

//instance of login view controller
@property (strong, nonatomic) LoginViewController *loginViewController;


// This function is called whenever a user's facebook session state changes.
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error;

// this function is called when user logs in the app using facebook authentication
- (void)userLoggedIn;

// this fucntion is called when a user logs out of the app i.e. facebook session
- (void)userLoggedOut;

@end
