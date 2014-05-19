//
//  RentOrBuyTableViewCell.h
//  Bookio
//
//  Created by Bookio Team on 4/25/14.
//  Copyright (c) 2014 Columbia University. All rights reserved.
//


// custom cell to display information about the user renting or selling his book
@interface RentOrBuyTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *UserId;
@property (strong, nonatomic) IBOutlet UILabel *Cost;
@property (strong, nonatomic) IBOutlet UIButton *sendTextMessage;
@property (strong, nonatomic) NSString *phoneNumber;
@end
