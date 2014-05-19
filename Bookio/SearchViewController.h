//
//  SearchViewController.h
//  Bookio
//
//  Created by Bookio Team on 4/20/14.
//  Copyright (c) 2014 Columbia University. All rights reserved.
//


// This view implements the table view protocols and text field protocols
@interface SearchViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

// this button is for the sidebar menu which can dragged in or out from the right side
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@property (strong, nonatomic) IBOutlet UITableView *SearchResultsTableView;
@property (strong, nonatomic) IBOutlet UIButton *SearchButton;
@property (strong, nonatomic) IBOutlet UITextField *courseNumber;
@property (strong, nonatomic) NSArray *ResultBooks;
@end
