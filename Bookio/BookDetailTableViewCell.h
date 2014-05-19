//
//  BookDetailTableViewCell.h
//  Bookio
//
//  Created by Bookio Team on 4/25/14.
//  Copyright (c) 2014 Columbia University. All rights reserved.
//

// custom table cell to dispay search results
@interface BookDetailTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *BookName;
@property (strong, nonatomic) IBOutlet UILabel *BookAuthor;
@property (strong, nonatomic) NSString *isbn;
@property (strong, nonatomic) NSString *Bname;
@end
