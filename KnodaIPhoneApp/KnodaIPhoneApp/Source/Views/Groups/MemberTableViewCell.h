//
//  MemberTableViewCell.h
//  KnodaIPhoneApp
//
//  Created by nick on 3/19/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MemberTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

+ (MemberTableViewCell *)cellForTableView:(UITableView *)tableView;

@end
