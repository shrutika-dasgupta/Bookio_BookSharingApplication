//
//  MyBooksTableViewCell.h
//  Bookio
//
//  Created by Bookio Team on 4/28/14.
//  Copyright (c) 2014 Columbia University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyBooksTableViewCell : UITableViewCell
//properties for UI fields in a cell
@property (weak, nonatomic) IBOutlet UILabel *MyBookName;
@property (weak, nonatomic) IBOutlet UILabel *MyBookAuthors;
@property (weak, nonatomic) IBOutlet UIButton *RentSelect;
@property (weak, nonatomic) IBOutlet UIButton *SellSelect;
@property (weak, nonatomic) IBOutlet UITextField *RentPrice;
@property (weak, nonatomic) IBOutlet UITextField *SellPrice;
//isbn of book representing this cell
@property (strong, nonatomic) NSString *isbn;

@end
