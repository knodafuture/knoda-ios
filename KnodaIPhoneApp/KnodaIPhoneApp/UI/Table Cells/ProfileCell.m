//
//  ProfileCell.m
//  KnodaIPhoneApp
//
//  Created by Vyacheslav Nechiporenko on 8/20/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "User.h"
#import "ProfileCell.h"
#import "BindableView.h"

@interface ProfileCell()

@property (weak, nonatomic) IBOutlet BindableView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

@end

@implementation ProfileCell

- (void)setupWithUser:(User *)user {
    self.userNameLabel.text = user.name;
    [self.avatarView bindToURL:user.thumbImage];
}

@end
