//
//  ProfileCell.h
//  KnodaIPhoneApp
//
//  Created by Vyacheslav Nechiporenko on 8/20/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "BaseTableViewCell.h"

@interface ProfileCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

@end
