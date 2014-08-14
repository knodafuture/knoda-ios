//
//  ContestDetailsViewController.h
//  KnodaIPhoneApp
//
//  Created by nick on 8/3/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Contest;
@class ContestTableViewCell;

@interface ContestDetailsViewController : UIViewController
@property (strong, nonatomic) ContestTableViewCell *headerView;

- (id)initWithContest:(Contest *)contest;


- (CGRect)rectForFirstTableViewCell;
- (UITableView *)tableView;
@end
