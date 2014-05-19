//
//  RentalsTableViewCell.h
//  Bookio
//
//  Created by Bookio Team on 4/29/14.
//  Copyright (c) 2014 Columbia University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RentalsTableViewCell : UITableViewCell
//properties for UI fields in a cell
@property (weak, nonatomic) IBOutlet UILabel *bookName;
@property (weak, nonatomic) IBOutlet UILabel *bookAuthors;
@property (weak, nonatomic) IBOutlet UILabel *userId;
@property (weak, nonatomic) IBOutlet UILabel *date;
//isbn of book representing this cell
@property (strong, nonatomic) NSString *isbn;
//course no this book belongs to
@property (strong, nonatomic) NSString *courseno;

@end
