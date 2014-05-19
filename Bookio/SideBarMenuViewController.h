//
//  SideBarMenuViewController.h
//  Bookio
//
//  Created by Bookio Team on 4/20/14.
//  Copyright (c) 2014 Columbia University. All rights reserved.
//

@interface SideBarMenuViewController : UITableViewController
{
    AppDelegate *appDelegate;
}
@property (nonatomic,retain) NSManagedObjectContext *managedObjectContext;

@end
