//
//  CreateGroupViewController.h
//  KnodaIPhoneApp
//
//  Created by nick on 3/21/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *GroupChangedNotificationName;
extern NSString *GroupChangedNotificationKey;
@class Group;
@interface CreateGroupViewController : UIViewController

- (id)initWithGroup:(Group *)group;

@end
