//
//  GetPhoneNoViewController.h
//  Bookio
//
//  Created by Bookio Team on 4/23/14.
//  Copyright (c) 2014 Columbia University. All rights reserved.
//

#import "LoginViewController.h"

@interface GetPhoneNoViewController : UIViewController<UITextFieldDelegate>
{
    //Application Delegate used for data passing across Views
    AppDelegate *delegateApp;
    
    //Application Delegate for accessing the Core data.
    AppDelegate *appDelegateCore;
}

//UI element for the Phone number text field
@property (strong, nonatomic) IBOutlet UITextField *PhoneNumber;

//UI element for the submit button
@property (strong, nonatomic) IBOutlet UIButton *SubmitPhoneNumber;

//For accessing the Core data information.
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end
