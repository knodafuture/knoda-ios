//
//  SocialContactsViewController.h
//  KnodaIPhoneApp
//
//  Created by nick on 8/25/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SocialFollowTableViewController.h"

@interface SocialContactsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak ,nonatomic) id<SocialFollowTableViewControllerDelegate> delegate;

- (id)initWithDelegate:(id<SocialFollowTableViewControllerDelegate>)delegate;

@property (readonly, nonatomic) NSArray *selectedMatches;
@property (readonly, nonatomic) NSArray *invitations;

@end
