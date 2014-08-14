//
//  RankingsTableViewController.h
//  KnodaIPhoneApp
//
//  Created by nick on 3/24/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Group;
@interface RankingsTableViewController : UITableViewController
@property (strong, nonatomic) NSArray *leaders;

- (id)initWithGroup:(Group *)group location:(NSString *)location;

@end
