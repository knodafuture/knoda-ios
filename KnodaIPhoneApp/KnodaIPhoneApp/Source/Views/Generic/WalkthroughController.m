//
//  WalkthroughController.m
//  KnodaIPhoneApp
//
//  Created by nick on 7/17/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "WalkthroughController.h"
#import "HomeViewController.h"
#import "UIImage+ImageEffects.h"
#import "UIView+Utils.h" 
#import "AppDelegate.h"
#import "NavigationViewController.h"
#import "AddPredictionViewController.h"
#import "UserManager.h"
#import "GenericWalkthroughView.h"

NSString *VotingWalkthroughCompleteNotificationName = @"VOTING_COMPLETE";
NSString *PredictWalkthroughCompleteNotificationName = @"PREDICTION_COMPLETE";
NSString *VotingDateWalkthroughCompleteNotificationName = @"VOTING_DATE_COMPLTE";

NSString *VotingWalkthroughCompleteKey = @"VOTING_COMPLETE_KEY";
NSString *PredictWalkthroughCompleteKey = @"PREDICT_COMPLETE_KEY";
NSString *VotingDateWalkthroughCompleteKey = @"VOTING_DATE_COMPLETE_KEY";


@interface WalkthroughController ()
@property (weak, nonatomic) HomeViewController *homeViewController;
@property (weak, nonatomic) AddPredictionViewController *addPredictionViewController;
@end

@implementation WalkthroughController

- (id)initWithTargetViewController:(HomeViewController *)viewController {
    self = [super init];
    self.homeViewController = viewController;
    
    return self;
}

- (id)initForAddPredictionViewController:(AddPredictionViewController *)viewController {
    self = [super init];
    self.addPredictionViewController = viewController;
    
    return self;
}

- (void)beginShowingWalkthroughIfNeeded {
    
    if (![UserManager sharedInstance].user)
        return;
    
    if (self.homeViewController)
        [self showForHome];
    else if (self.addPredictionViewController)
        [self showForAddPrediction];
}

- (void)showForHome {
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:FirstLaunchKey])
        return;
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:VotingWalkthroughCompleteKey])
        [self showVotingWalkthrough];
    else if (![[NSUserDefaults standardUserDefaults] boolForKey:PredictWalkthroughCompleteKey])
        [self showPredictionWalkthrough];
}

- (void)showForAddPrediction {
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:VotingDateWalkthroughCompleteKey])
        [self showVotingDateWalkthrough];
    
}

- (void)showVotingDateWalkthrough {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(completeVotingDateWalkthrough) name:VotingDateWalkthroughCompleteNotificationName object:nil];
    
    GenericWalkthroughView *walkthrough = [[GenericWalkthroughView alloc] init];
    
    CGRect rect = self.addPredictionViewController.categoryBar.frame;
    
    [walkthrough addBlur:self.addPredictionViewController.view destinationRect:rect];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(completeVotingDateWalkthrough)];
    [walkthrough addGestureRecognizer:tap];
    
    [walkthrough prepareWithTitle:@"CHOOSING A VOTING DATE" body:@"Knoda users can vote on your prediction until this time. Be sure to choose a date before the result of your prediction is known." direction:YES];

    [self.addPredictionViewController.view addSubview:walkthrough];
    self.currentWalkthrough = walkthrough;
    
    [walkthrough smallerFont];
    
    [UIView animateWithDuration:0.5 animations:^{
        walkthrough.alpha = 1.0;
    }];
}

- (void)completeVotingDateWalkthrough {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:VotingDateWalkthroughCompleteKey];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [UIView animateWithDuration:0.5 animations:^{
        ((UIView *)self.currentWalkthrough).alpha = 0.0;
    } completion:^(BOOL finished) {
        [self beginShowingWalkthroughIfNeeded];
    }];
}

- (void)showVotingWalkthrough {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(completeVotingWalkthrough) name:VotingWalkthroughCompleteNotificationName object:nil];
    
    CGRect rect =[self.homeViewController.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    rect.origin.y = rect.origin.y + rect.size.height;
    
    GenericWalkthroughView *walkthrough = [[GenericWalkthroughView alloc] init];
    
    [walkthrough addBlur:self.homeViewController.parentViewController.view destinationRect:rect];
    [walkthrough prepareWithTitle:@"CHOOSE A SIDE" body:@"Swipe right to agree or swipe left to disagree with a prediction. Give it a try!" direction:YES];

    [self.homeViewController.tableView addSubview:walkthrough];
    self.currentWalkthrough = walkthrough;
    
    
    [UIView animateWithDuration:0.5 animations:^{
        walkthrough.alpha = 1.0;
    }];

}

- (void)completeVotingWalkthrough {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:VotingWalkthroughCompleteKey];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [UIView animateWithDuration:0.5 animations:^{
        ((UIView *)self.currentWalkthrough).alpha = 0.0;
    } completion:^(BOOL finished) {
        [self beginShowingWalkthroughIfNeeded];
    }];
    
}

- (void)showPredictionWalkthrough {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(completePredictWalkthrough) name:PredictWalkthroughCompleteNotificationName object:nil];
    GenericWalkthroughView *walkthrough = [[GenericWalkthroughView alloc] init];

    CGRect rect = CGRectMake(0, self.homeViewController.view.frame.size.height - walkthrough.frame.size.height, walkthrough.frame.size.width, walkthrough.frame.size.height - 5.0);

    [walkthrough addBlur:self.homeViewController.parentViewController.view destinationRect:rect];
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(completePredictWalkthrough)];
    [walkthrough addGestureRecognizer:tap];
    
    [walkthrough prepareWithTitle:@"MAKE A PREDICTION" body:@"Now that you're acquainted with Knoda, tap the predict icon to make your first prediction." direction:NO];
    
    [window.rootViewController.view addSubview:walkthrough];
    
    self.currentWalkthrough = walkthrough;
    self.homeViewController.tableView.userInteractionEnabled = NO;
    
    CGRect frame = walkthrough.frame;
    frame.origin.y += 20 + 36;
    walkthrough.frame = frame;
    
    [(NavigationViewController *)window.rootViewController setTabBarEnabled:NO];
    [UIView animateWithDuration:0.5 animations:^{
        walkthrough.alpha = 1.0;
    }];
}

- (void)completePredictWalkthrough {
    self.homeViewController.tableView.userInteractionEnabled = YES;
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    [(NavigationViewController *)window.rootViewController setTabBarEnabled:YES];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:PredictWalkthroughCompleteKey];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:FirstLaunchKey];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [UIView animateWithDuration:0.5 animations:^{
        ((UIView *)self.currentWalkthrough).alpha = 0.0;
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeAllObservations];
}

@end
