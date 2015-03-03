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
#import "GenericWalkthroughView.h"

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
    
    GenericWalkthroughView *walkthrough = [[GenericWalkthroughView alloc] init];
    
    CGRect rect = [self.viewController rectForFirstTableViewCell];
    rect.origin.y += rect.size.height;
    
    [walkthrough addBlur:self.viewController.view destinationRect:rect];
    
    [walkthrough prepareWithTitle:@"HOW TO JOIN THE CONTEST" body:@"Vote on a Live Prediction and you're eligible to win. Boom! It's that easy" direction:YES];
    [self.viewController.tableView addSubview:walkthrough];
    self.currentWalkthrough = walkthrough;
    
    [UIView animateWithDuration:0.5 animations:^{
        walkthrough.alpha = 1.0;
    }];
}

- (void)completeContestVoteWalkthrough {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:ContestVoteWalkthroughNotificationKey];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [UIView animateWithDuration:0.5 animations:^{
        ((UIView *)self.currentWalkthrough).alpha = 0.0;
    } completion:^(BOOL finished) {
        [self beginShowingWalkthroughIfNeeded];
    }];
}

- (void)showContestSuccessWalkthrough {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(completeContestSuccessWalkthrough) name:ContestVoteWalkthroughCompleteNotificationName object:nil];
    
    GenericWalkthroughView *walkthrough = [[GenericWalkthroughView alloc] init];
    
    [self.viewController.tableView scrollRectToVisible:self.viewController.tableView.frame animated:NO];
    CGRect rect = self.viewController.headerView.frame;
    rect.origin.y += rect.size.height;

    [walkthrough addBlur:self.viewController.view destinationRect:rect];
    
    [walkthrough prepareWithTitle:@"RIGHT ON!" body:@"Now that you've voted, this contest will show up under your 'My Contests' tab." direction:YES];
    
    [self.viewController.view addSubview:walkthrough];
    self.currentWalkthrough = walkthrough;
    
    self.viewController.tableView.userInteractionEnabled = NO;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(completeContestSuccessWalkthrough)];
    [walkthrough addGestureRecognizer:tap];
    
    [UIView animateWithDuration:0.5 animations:^{
        walkthrough.alpha = 1.0;
    }];
}

- (void)completeContestSuccessWalkthrough {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:ContestSuccessWalkthroughNotificationKey];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.viewController.tableView.userInteractionEnabled = YES;
    [UIView animateWithDuration:0.5 animations:^{
        ((UIView *)self.currentWalkthrough).alpha = 0.0;
    } completion:^(BOOL finished) {
        [self beginShowingWalkthroughIfNeeded];
    }];
}


@end
