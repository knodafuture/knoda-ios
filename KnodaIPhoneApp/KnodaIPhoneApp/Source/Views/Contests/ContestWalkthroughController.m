//
//  ContestWalkthroughController.m
//  KnodaIPhoneApp
//
//  Created by nick on 8/11/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "ContestWalkthroughController.h"
#import "ContestDetailsViewController.h"
#import "UIView+Utils.h"
#import "UIImage+ImageEffects.h"
#import "ContestTableViewCell.h"

NSString *ContestVoteWalkthroughCompleteNotificationName = @"CONTESTVOTEWALKTHROUGHCOMPLETE";
NSString *ContestVoteWalkthroughNotificationKey = @"CONTESTVOTEWLAKTHROUGHCOMPLTEKEY";
NSString *ContestSuccessWalkthroughCompleteNotificationName = @"CONTESTSUCCESSWALKTHROUGHCOMPLETE";
NSString *ContestSuccessWalkthroughNotificationKey = @"CONTESTSUCCESSWALKTHROUGHCOMPLTEKEY";

@interface ContestWalkthroughController ()
@property (weak, nonatomic) ContestDetailsViewController *viewController;

@end
@implementation ContestWalkthroughController

- (id)initForContestDetailsViewController:(ContestDetailsViewController *)viewController {
    self = [super init];
    
    self.viewController = viewController;
    
    return self;
}

- (void)beginShowingWalkthroughIfNeeded {
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:ContestVoteWalkthroughNotificationKey])
        [self showContestVoteWalkthrough];
    else if (![[NSUserDefaults standardUserDefaults] boolForKey:ContestSuccessWalkthroughNotificationKey])
        [self showContestSuccessWalkthrough];
    
}


- (void)showContestVoteWalkthrough {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(completeContestVoteWalkthrough) name:ContestVoteWalkthroughCompleteNotificationName object:nil];
    
    UIImage *capture = [self.viewController.view captureView];
    
    UIImage *walkthroughImage = [UIImage imageNamed:@"ContestVoteWalkThru"];
    
    CGRect rect = [self.viewController rectForFirstTableViewCell];
    
    CGImageRef croppedRef = CGImageCreateWithImageInRect(capture.CGImage, CGRectMake(0, rect.origin.y + rect.size.height, walkthroughImage.size.width, walkthroughImage.size.height - 5.0));
    
    UIImage *croppedImage = [UIImage imageWithCGImage:croppedRef];
    CGImageRelease(croppedRef);
    
    croppedImage = [croppedImage applyExtraLightEffect];
    UIView *walkthroughView = [[UIView alloc] initWithFrame:CGRectMake(0, rect.origin.y + rect.size.height - 5.0, walkthroughImage.size.width, walkthroughImage.size.height)];
    UIImageView *background = [[UIImageView alloc] initWithImage:croppedImage];
    CGRect frame = background.frame;
    frame.origin.y = 5.0;
    background.frame = frame;
    [walkthroughView addSubview:background];
    
    UIImageView *foreground = [[UIImageView alloc] initWithImage:walkthroughImage];
    [walkthroughView addSubview:foreground];
    
    walkthroughView.backgroundColor = [UIColor clearColor];
    
    walkthroughView.alpha = 0.0;
    
    [self.viewController.tableView addSubview:walkthroughView];
    self.currentWalkthrough = walkthroughView;
    
    [UIView animateWithDuration:0.5 animations:^{
        walkthroughView.alpha = 1.0;
    }];
}

- (void)completeContestVoteWalkthrough {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:ContestVoteWalkthroughNotificationKey];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.currentWalkthrough.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self beginShowingWalkthroughIfNeeded];
    }];
}

- (void)showContestSuccessWalkthrough {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(completeContestSuccessWalkthrough) name:ContestVoteWalkthroughCompleteNotificationName object:nil];
    
    [self.viewController.tableView scrollRectToVisible:self.viewController.tableView.frame animated:NO];
    
    UIImage *capture = [self.viewController.view captureView];
    
    UIImage *walkthroughImage = [UIImage imageNamed:@"ContestAddedWalkThru"];
    
    CGRect rect = self.viewController.headerView.frame;
    
    CGImageRef croppedRef = CGImageCreateWithImageInRect(capture.CGImage, CGRectMake(0, rect.origin.y + rect.size.height, walkthroughImage.size.width, walkthroughImage.size.height - 5.0));
    
    UIImage *croppedImage = [UIImage imageWithCGImage:croppedRef];
    CGImageRelease(croppedRef);
    
    croppedImage = [croppedImage applyExtraLightEffect];
    UIView *walkthroughView = [[UIView alloc] initWithFrame:CGRectMake(0, rect.origin.y + rect.size.height - 5.0, walkthroughImage.size.width, walkthroughImage.size.height)];
    UIImageView *background = [[UIImageView alloc] initWithImage:croppedImage];
    CGRect frame = background.frame;
    frame.origin.y = 5.0;
    background.frame = frame;
    [walkthroughView addSubview:background];
    
    UIImageView *foreground = [[UIImageView alloc] initWithImage:walkthroughImage];
    [walkthroughView addSubview:foreground];
    
    walkthroughView.backgroundColor = [UIColor clearColor];
    
    walkthroughView.alpha = 0.0;
    
    [self.viewController.view addSubview:walkthroughView];
    self.currentWalkthrough = walkthroughView;
    
    self.viewController.tableView.userInteractionEnabled = NO;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(completeContestSuccessWalkthrough)];
    [walkthroughView addGestureRecognizer:tap];
    
    [UIView animateWithDuration:0.5 animations:^{
        walkthroughView.alpha = 1.0;
    }];
}

- (void)completeContestSuccessWalkthrough {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:ContestSuccessWalkthroughNotificationKey];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.viewController.tableView.userInteractionEnabled = YES;
    [UIView animateWithDuration:0.5 animations:^{
        self.currentWalkthrough.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self beginShowingWalkthroughIfNeeded];
    }];
}


@end
