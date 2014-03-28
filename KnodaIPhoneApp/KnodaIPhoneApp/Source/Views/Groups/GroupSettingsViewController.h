//
//  GroupSettingsViewController.h
//  KnodaIPhoneApp
//
//  Created by nick on 3/19/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "BaseTableViewController.h"
@class Group;

@interface GroupSettingsViewController : UIViewController

- (id)initWithGroup:(Group *)group;
- (id)initWithNewlyCreatedGroup:(Group *)group;
- (id)initWithGroup:(Group *)group invitationCode:(NSString *)invitationCode;

@end
