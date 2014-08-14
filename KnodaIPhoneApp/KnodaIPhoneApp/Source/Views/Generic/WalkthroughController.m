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
    
    UIImage *capture = [self.addPredictionViewController.view captureView];
    
    UIImage *walkthroughImage = [UIImage imageNamed:@"VotingDateWalkThru"];
    
    CGRect rect = self.addPredictionViewController.expirationBar.frame;
    
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
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(completeVotingDateWalkthrough)];
    [walkthroughView addGestureRecognizer:tap];
    
    [self.addPredictionViewController.view addSubview:walkthroughView];
    self.currentWalkthrough = walkthroughView;
    
    [UIView animateWithDuration:0.5 animations:^{
        walkthroughView.alpha = 1.0;
    }];
}

- (void)completeVotingDateWalkthrough {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:VotingDateWalkthroughCompleteKey];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.currentWalkthrough.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self beginShowingWalkthroughIfNeeded];
    }];
}

- (void)showVotingWalkthrough {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(completeVotingWalkthrough) name:VotingWalkthroughCompleteNotificationName object:nil];
    
    UIImage *capture = [self.homeViewController.view captureView];
    
    UIImage *walkthroughImage = [UIImage imageNamed:@"VoteWalkthru"];
    
    CGRect rect =[self.homeViewController.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
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
    
    [self.homeViewController.view addSubview:walkthroughView];
    self.currentWalkthrough = walkthroughView;
    
    [UIView animateWithDuration:0.5 animations:^{
        walkthroughView.alpha = 1.0;
    }];
}

- (void)completeVotingWalkthrough {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:VotingWalkthroughCompleteKey];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.currentWalkthrough.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self beginShowingWalkthroughIfNeeded];
    }];
    
}

- (void)showPredictionWalkthrough {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(completePredictWalkthrough) name:PredictWalkthroughCompleteNotificationName object:nil];
    UIImage *capture = [self.homeViewController.view captureView];
    
    UIImage *walkthroughImage = [UIImage imageNamed:@"PredictWalkthru"];
    
    CGRect rect = CGRectMake(0, self.homeViewController.view.frame.size.height - walkthroughImage.size.height - 5.0, walkthroughImage.size.width, walkthroughImage.size.height - 5.0);
    
    CGImageRef croppedRef = CGImageCreateWithImageInRect(capture.CGImage, rect);
    
    UIImage *croppedImage = [UIImage imageWithCGImage:croppedRef];
    CGImageRelease(croppedRef);
    
    croppedImage = [croppedImage applyExtraLightEffect];
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    CGPoint convertedPoint = CGPointMake(0, rect.origin.y + 20 + 44);//[window convertPoint:rect.origin fromView:self.viewController.view];
    UIView *walkthroughView = [[UIView alloc] initWithFrame:CGRectMake(0, convertedPoint.y, walkthroughImage.size.width, walkthroughImage.size.height)];
    
    UIImageView *background = [[UIImageView alloc] initWithImage:croppedImage];
    [walkthroughView addSubview:background];
    
    UIImageView *foreground = [[UIImageView alloc] initWithImage:walkthroughImage];
    [walkthroughView addSubview:foreground];
    
    walkthroughView.backgroundColor = [UIColor clearColor];
    
    walkthroughView.alpha = 0.0;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(completePredictWalkthrough)];
    [walkthroughView addGestureRecognizer:tap];
    
    [window.rootViewController.view addSubview:walkthroughView];
    self.currentWalkthrough = walkthroughView;
    self.homeViewController.tableView.userInteractionEnabled = NO;
    [(NavigationViewController *)window.rootViewController setTabBarEnabled:NO];
    [UIView animateWithDuration:0.5 animations:^{
        walkthroughView.alpha = 1.0;
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
        self.currentWalkthrough.alpha = 0.0;
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeAllObservations];
}

@end
