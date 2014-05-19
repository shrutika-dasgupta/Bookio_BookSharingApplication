//
//  AddRentedTableViewCell.h
//  Bookio
//
//  Created by Bookio Team on 4/30/14.
//  Copyright (c) 2014 Columbia University. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddRentalCellDelegate <NSObject>

@optional
-(void)addRentalButtonPressedAtIndexpath:(NSIndexPath*)path;

@end

@interface AddRentedTableViewCell : UITableViewCell
@property(nonatomic, strong)id <AddRentalCellDelegate> delegate;

//properties for UI fields in a cell
@property (weak, nonatomic) IBOutlet UILabel *bookName;
@property (weak, nonatomic) IBOutlet UILabel *bookAuthors;
@property (weak, nonatomic) IBOutlet UITextField *rentedTo;
@property (weak, nonatomic) IBOutlet UITextField *tillDate;
@property (weak, nonatomic) IBOutlet UIButton *addToRentals;

//isbn of book representing this cell
@property (strong, nonatomic) NSString *isbn;

//holds the indexPath of the cell
@property(nonatomic, strong) NSIndexPath *path;

@end
