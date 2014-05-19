//
//  SearchResultViewController.h
//  Bookio
//
//  Created by Bookio Team on 4/22/14.
//  Copyright (c) 2014 Columbia University. All rights reserved.
//

// imported the message Framework to allow the app to send text messages
// Ref: http://www.appcoda.com/ios-programming-send-sms-text-message/

#import <MessageUI/MessageUI.h>

@interface SearchResultViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MFMessageComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (strong, nonatomic) IBOutlet UITableView *RentOrBuyTableView;

// stores details of books which are available for renting
@property (nonatomic, strong) NSMutableArray *RentUsers;

// stores details of books which are available for buying
@property (nonatomic, strong) NSMutableArray *BuyUsers;

@property (strong, nonatomic) id isbn;
@property (strong, nonatomic) id book_name;

//instance of coredata managedObejctContext variable.
@property (nonatomic,retain) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) NSString *myUserID;

@end
