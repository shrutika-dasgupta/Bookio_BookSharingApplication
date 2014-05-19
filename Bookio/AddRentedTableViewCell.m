//
//  AddRentedTableViewCell.m
//  Bookio
//
//  Created by Bookio Team on 4/30/14.
//  Copyright (c) 2014 Columbia University. All rights reserved.
//

#import "AddRentedTableViewCell.h"

@implementation AddRentedTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)finishedUserIdEdit:(id)sender {
    //resign the keyboard
    if (self.addToRentals.isFirstResponder) {
        [self.addToRentals resignFirstResponder];
    }
}

- (IBAction)finishedDateEdit:(id)sender {
    //resign the keyboard
    if (self.addToRentals.isFirstResponder) {
        [self.addToRentals resignFirstResponder];
    }
}

- (IBAction)addButtonPressed:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(addRentalButtonPressedAtIndexpath:)]) {
        
        //activate delegate method
        [self.delegate addRentalButtonPressedAtIndexpath:self.path];
    }

}


@end
