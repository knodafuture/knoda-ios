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

#import <QuartzCore/QuartzCore.h>

@interface NewBadgeView()

@property (weak, nonatomic) IBOutlet UIImageView *badgeImageView;

@end

@implementation NewBadgeView

+ (void)showWithBadge:(UIImage *)badgeImage animated:(BOOL)animated {
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    
    NewBadgeView *badgeView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil] lastObject];
    badgeView.frame = window.bounds;
    badgeView.badgeImageView.image = badgeImage;
    
    if(animated) {
        badgeView.layer.affineTransform = CGAffineTransformMakeScale(0.01, 0.01);
        
        [window addSubview:badgeView];
        
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            badgeView.layer.affineTransform = CGAffineTransformIdentity;
        } completion:nil];
    }
    else {
        [window addSubview:badgeView];
    }
}

- (IBAction)viewBadges:(UIButton *)sender {
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    UINavigationController *rootVC = (UINavigationController *)[window rootViewController];
    
    if(![rootVC.topViewController isKindOfClass:[NavigationViewController class]]) {
        DLog(@"cannot find NavigationViewController");
        [self close:nil];
        return;
    }
    
    NavigationViewController *nc = (NavigationViewController *)rootVC.topViewController;
    
    [nc.detailsController dismissViewControllerAnimated:NO completion:nil];
    
    if(nc.masterShown || [nc.detailsController.topViewController isKindOfClass:[BadgesCollectionViewController class]]) {
        [nc openMenuItem:MenuBadges];
    }
    else {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
        BadgesCollectionViewController *vc = (BadgesCollectionViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BadgesCollectionViewController"];
        
        [nc.detailsController popToRootViewControllerAnimated:NO];
        [nc.detailsController pushViewController:vc animated:YES];
    }
    
    [self removeFromSuperview];
}

- (IBAction)close:(UIButton *)sender {
    [self removeFromSuperview];
}

@end
