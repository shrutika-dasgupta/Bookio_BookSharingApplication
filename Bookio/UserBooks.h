//
//  UserBooks.h
//  Bookio
//
//  Created by Bookio Team on 4/28/14.
//  Copyright (c) 2014 Columbia University. All rights reserved.
//



@interface UserBooks : NSManagedObject

@property (nonatomic, retain) NSString * isbn;
@property (nonatomic, retain) NSNumber * rent;
@property (nonatomic, retain) NSNumber * rent_cost;
@property (nonatomic, retain) NSNumber * sell;
@property (nonatomic, retain) NSNumber * sell_cost;
@property (nonatomic, retain) NSString * user_id;
@property (nonatomic, retain) NSString * courseno;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * authors;
@end
