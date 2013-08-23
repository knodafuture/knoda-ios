//
//  NewBadgePopup.m
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 23.08.13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "NewBadgeView.h"
#import "BadgesCollectionViewController.h"
#import "NavigationViewController.h"

@interface NewBadgeView()

@property (weak, nonatomic) IBOutlet UIImageView *badgeImageView;

@end

@implementation NewBadgeView

+ (void)showWithBadge:(UIImage *)badgeImage {
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    
    NewBadgeView *badgeView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] lastObject];
    badgeView.frame = window.bounds;
    badgeView.badgeImageView.image = badgeImage;
    
    [window addSubview:badgeView];
}

- (IBAction)viewBadges:(UIButton *)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
    BadgesCollectionViewController *vc = (BadgesCollectionViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgesCollectionViewController"];
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    UINavigationController *rootVC = (UINavigationController *)[window rootViewController];
    
    NavigationViewController *nc = (NavigationViewController *)rootVC.topViewController;
    
    [nc.detailsController dismissViewControllerAnimated:NO completion:nil];
    [nc.detailsController popToRootViewControllerAnimated:NO];
    [nc.detailsController pushViewController:vc animated:YES];
    [self removeFromSuperview];
}

- (IBAction)close:(UIButton *)sender {
    [self removeFromSuperview];
}

@end
