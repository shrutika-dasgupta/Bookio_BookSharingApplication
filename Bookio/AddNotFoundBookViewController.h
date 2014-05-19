//
//  AddNotFoundBookViewController.h
//  Bookio
//
//  Created by Bookio Team on 4/27/14.
//  Copyright (c) 2014 Columbia University. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import "UserBooks.h"

// This class implements the functionality --> when a user wants to add a book to his my books but the book is not in our central database, then the user can request the admin  to update the central database by adding this book.
@interface AddNotFoundBookViewController : UIViewController <MFMessageComposeViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (strong, nonatomic) IBOutlet UITextField *isbnText;
@property (strong, nonatomic) IBOutlet UITextField *bookNameText;
@property (strong, nonatomic) IBOutlet UITextField *bookAuthorText;
@property (strong, nonatomic) IBOutlet UITextField *courseNoText;
@property (strong, nonatomic) IBOutlet UIButton *addBookButton;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@end
