//
//  UserProfileHeaderView.m
//  KnodaIPhoneApp
//
//  Created by Nick R on 11/20/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "UserProfileHeaderView.h"
#import "User.h"
#import "WebApi.h"
#import "UserManager.h"

static UINib *nib;

@interface UserProfileHeaderView ()
@property (weak, nonatomic) id<UserProfileHeaderViewDelegate> delegate;
@property (strong, nonatomic) User *user;
@end

@implementation UserProfileHeaderView

+ (void)initialize {
    nib = [UINib nibWithNibName:@"UserProfileHeaderView" bundle:[NSBundle mainBundle]];
}

- (id)initWithDelegate:(id<UserProfileHeaderViewDelegate>)delegate {
    self = [[nib instantiateWithOwner:nil options:nil] lastObject];
    self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.height / 2.0;
    self.avatarImageView.clipsToBounds = YES;
    self.avatarImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.avatarImageView.layer.borderWidth = 1.0;
    self.delegate = delegate;
    
    [self observeNotification:UserChangedNotificationName withBlock:^(__weak UserProfileHeaderView *self, NSNotification *notification) {
        
        if (self.user.user_id == [UserManager sharedInstance].user.user_id)
            [self populateWithUser:[UserManager sharedInstance].user];
    }];
    
    return self;
}


- (void)populateWithUser:(User *)user {
    
    self.user = user;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setGroupingSeparator:[[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator]];
    
    self.pointsLabel.text = [NSString stringWithFormat:@"%@", [formatter stringFromNumber:[NSNumber numberWithInteger:user.points]]];
    if ([user.winningPercentage isEqual:@0])
        self.winPercentLabel.text = @"0%";
    else if ([user.winningPercentage isEqual:@100])
        self.winPercentLabel.text = @"100%";
    else
        self.winPercentLabel.text = [NSString stringWithFormat:@"%3.2f%@",user.winningPercentage.floatValue,@"%"];    self.streakLabel.text = [user.streak length] > 0 ? user.streak : @"W0";
    self.winLossLabel.text = [NSString stringWithFormat:@"%lu-%lu",(unsigned long)user.won,(unsigned long)user.lost];
    
    [[WebApi sharedInstance] getImage:user.avatar.big completion:^(UIImage *image, NSError *error) {
        if (!error)
            self.avatarImageView.image = image;
    }];
    
    self.followerCountLabel.text = [NSString stringWithFormat:@"%ld", (long)user.followerCount];
    self.followingCountLabel.text = [NSString stringWithFormat:@"%ld", (long)user.followingCount];
}

- (IBAction)avatarPress:(id)sender {
    if ([self.delegate respondsToSelector:@selector(avatarButtonPressedInHeaderView:)])
        [self.delegate avatarButtonPressedInHeaderView:self];
}

- (IBAction)followersPressed:(id)sender {
    [self.delegate followersPressedInHeaderView:self];
}

- (IBAction)followingPressed:(id)sender {
    [self.delegate followingPressedInHeaderView:self];  
}

- (void)dealloc {
    [self removeAllObservations];
}
@end
