//
//  UserCell.h
//  KnodaIPhoneApp
//
//  Created by nick on 1/2/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>
@class User;
@interface UserCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) User *user;

+ (UserCell *)userCellForTableView:(UITableView *)tableView;
@end
