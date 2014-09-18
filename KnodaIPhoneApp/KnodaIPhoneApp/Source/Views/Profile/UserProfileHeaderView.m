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
#import "HeadToHeadBarView.h"

static UINib *nib;

@interface UserProfileHeaderView () <UIScrollViewDelegate>
@property (weak, nonatomic) id<UserProfileHeaderViewDelegate> delegate;
@property (strong, nonatomic) User *user;
@property (assign, nonatomic) BOOL showHeadToHead;
@property (strong, nonatomic) HeadToHeadBarView *barView;
@end

@implementation UserProfileHeaderView

+ (void)initialize {
    nib = [UINib nibWithNibName:@"UserProfileHeaderView" bundle:[NSBundle mainBundle]];
}

- (id)initWithDelegate:(id<UserProfileHeaderViewDelegate>)delegate showHeadToHead:(BOOL)showHeadToHead {
    self = [[nib instantiateWithOwner:nil options:nil] firstObject];
    self.showHeadToHead = showHeadToHead;
    self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.height / 2.0;
    self.avatarImageView.clipsToBounds = YES;
    self.avatarImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.avatarImageView.layer.borderWidth = 1.0;
    
    
    if (self.showHeadToHead) {
        self.barView = [[HeadToHeadBarView alloc] init];
        CGRect frame = self.barView.frame;
        
        [self.headToHeadView addSubview:self.barView];
        frame.origin.y = (self.headToHeadView.frame.size.height / 2.0) - (frame.size.height / 2.0) + 10.0;
        frame.origin.x = (self.headToHeadView.frame.size.width / 2.0) - (frame.size.width / 2.0);
        self.barView.frame = frame;
        
        self.barView.leftLabel.textColor = [UIColor whiteColor];
        self.barView.rightLabel.textColor = [UIColor whiteColor];
        self.barView.visitingUserLabel.hidden = YES;
        frame = self.statsView.frame;
        frame.origin.x = 0;
        [self.scrollView addSubview:self.statsView];
        frame = self.headToHeadView.frame;
        frame.origin.x = self.scrollView.frame.size.width;
        self.headToHeadView.frame = frame;
        [self.scrollView addSubview:self.headToHeadView];
        self.pageControl.hidden = NO;
        
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * 2, self.scrollView.frame.size.height);
    
        self.pageControl.numberOfPages = 2;
    } else {
        CGRect frame = self.statsView.frame;
        frame.origin.x = 0;
        [self.scrollView addSubview:self.statsView];
        self.scrollView.contentSize = self.scrollView.frame.size;
        self.pageControl.hidden = YES;
        self.scrollView.scrollEnabled = NO;
        frame = self.frame;
        frame.size.height -= self.pageControl.frame.size.height;
        frame.size.height += 5.0;
        self.frame = frame;
    }
    
    
    self.delegate = delegate;
    
    [self observeNotification:UserChangedNotificationName withBlock:^(__weak UserProfileHeaderView *self, NSNotification *notification) {
        
        if (self.user.user_id == [UserManager sharedInstance].user.userId)
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
        if (!error) {
            self.avatarImageView.image = image;
            
            if (self.showHeadToHead) {
                self.headToHeadRivalImageView.image = image;
                [[WebApi sharedInstance] getImage:[UserManager sharedInstance].user.avatar.small completion:^(UIImage *image, NSError *error) {
                    if (!error)
                        self.headToHeadMyImageView.image = image;
                }];
            }
        }
    }];
    
    self.followerCountLabel.text = [NSString stringWithFormat:@"%ld", (long)user.followerCount];
    self.followingCountLabel.text = [NSString stringWithFormat:@"%ld", (long)user.followingCount];
    
    
    
    if (self.showHeadToHead) {
        [self.barView populateWithLeftUser:[UserManager sharedInstance].user rightUser:user animated:NO];
        
        [[WebApi sharedInstance] getImage:[UserManager sharedInstance].user.avatar.small completion:^(UIImage *image, NSError *error) {
            if (image)
                self.barView.leftImageView.image = image;
        }];
        
        [[WebApi sharedInstance] getImage:user.avatar.small completion:^(UIImage *image, NSError *error) {
            if (image)
                self.barView.rightImageView.image = image;
        }];
    }
    
    
}

- (UIView *)viewForWins:(NSInteger)wins width:(CGFloat)width left:(BOOL)left {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 25.0)];
    view.backgroundColor = [UIColor colorFromHex:@"235C37"];
    
    UILabel *label = [[UILabel alloc] initWithFrame:view.frame];
    label.textAlignment = left ? NSTextAlignmentRight : NSTextAlignmentLeft;
    CGRect frame = label.frame;
    frame.origin.x = left ? 0 : 25.0;
    frame.size.width = left ? frame.size.width - 25.0 : 0;
    label.frame = frame;
    
    label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15.0];
    label.textColor = [UIColor whiteColor];
    label.text = [NSString stringWithFormat:@"%ld", (long)wins];
    [view addSubview:label];
    
    return view;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.pageControl.currentPage =   lround(scrollView.contentOffset.x / scrollView.frame.size.width);
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
