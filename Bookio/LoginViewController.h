//
//  LoginViewController.h
//  Bookio
//
//  Created by Bookio Team on 4/20/14.
//  Copyright (c) 2014 Columbia University. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>

@interface LoginViewController : UIViewController <FBLoginViewDelegate>

//UI element for the login button
@property (strong, nonatomic) IBOutlet UIButton *loginButton;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

//UI Action for the login button whne clicked.
- (IBAction)LoginButtonClicked:(UIButton *)sender;

@end