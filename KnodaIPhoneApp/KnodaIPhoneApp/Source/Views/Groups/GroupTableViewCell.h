//
//  GroupTableViewCell.h
//  KnodaIPhoneApp
//
//  Created by nick on 3/17/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupTableViewCell : UITableViewCell

+ (GroupTableViewCell *)cellForTableView:(UITableView *)tableView;


@property (weak, nonatomic) IBOutlet UIImageView *groupImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *rankLabel;
@property (weak, nonatomic) IBOutlet UILabel *rankDetailsLabel;
@property (weak, nonatomic) IBOutlet UILabel *leaderNameLabel;

@end
