//
//  AutocompleteMentionTableViewCell.h
//  KnodaIPhoneApp
//
//  Created by nick on 10/11/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AutocompleteMentionTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

+ (AutocompleteMentionTableViewCell *)cellForTableView:(UITableView *)tableView;

@end
