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
#import "UIView+Test.h" 

NSString *VotingWalkthroughCompleteNotificationName = @"VOTING_COMPLETE";
NSString *PredictWalkthroughCompleteNotificationName = @"PREDICTION_COMPLETE";

NSString *VotingWalkthroughCompleteKey = @"VOTING_COMPLETE_KEY";
NSString *PredictWalkthroughCompleteKey = @"PREDICT_COMPLETE_KEY";

@interface WalkthroughController ()
@property (weak, nonatomic) HomeViewController *viewController;
@property (strong, nonatomic) UIView *currentWalkthrough;
@end

@implementation WalkthroughController

- (id)initWithTargetViewController:(HomeViewController *)viewController {
    self = [super init];
    self.viewController = viewController;
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:VotingWalkthroughCompleteKey];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:PredictWalkthroughCompleteKey];
    return self;
}

- (void)beginShowingWalkthroughIfNeeded {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:VotingWalkthroughCompleteKey])
        [self showVotingWalkthrough];
    else if (![[NSUserDefaults standardUserDefaults] boolForKey:PredictWalkthroughCompleteKey])
        [self showPredictionWalkthrough];
}

- (void)showVotingWalkthrough {
    
    [self observeNotification:VotingWalkthroughCompleteNotificationName withBlock:^(__weak WalkthroughController *self, NSNotification *notification) {
        //[self completeVotingWalkthrough];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(completeVotingWalkthrough) name:VotingWalkthroughCompleteNotificationName object:nil];
    
    UIImage *capture = [self.viewController.view captureView];
    
    UIImage *walkthroughImage = [UIImage imageNamed:@"VoteWalkthru"];
    
    CGRect rect =[self.viewController.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
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
    
    walkthroughView.alpha = 1.0;
    
    [self.viewController.tableView addSubview:walkthroughView];
    self.currentWalkthrough = walkthroughView;
    [UIView animateWithDuration:1.0 animations:^{
        walkthroughView.alpha = 1.0;
    }];
}

- (void)completeVotingWalkthrough {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:VotingWalkthroughCompleteKey];
    [self removeAllObservations];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.currentWalkthrough.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self beginShowingWalkthroughIfNeeded];
    }];
    
}

- (void)showPredictionWalkthrough {
    [self observeNotification:PredictWalkthroughCompleteNotificationName withBlock:^(__weak WalkthroughController *self, NSNotification *notification) {
        [self completePredictWalkthrough];
    }];
    
    UIImage *capture = [self.viewController.view captureView];
    
    UIImage *walkthroughImage = [UIImage imageNamed:@"PredictWalkthru"];
    
    CGRect rect = CGRectMake(0, self.viewController.view.frame.size.height - walkthroughImage.size.height - 5.0, walkthroughImage.size.width, walkthroughImage.size.height - 5.0);
    
    CGImageRef croppedRef = CGImageCreateWithImageInRect(capture.CGImage, rect);
    
    UIImage *croppedImage = [UIImage imageWithCGImage:croppedRef];
    CGImageRelease(croppedRef);
    
    croppedImage = [croppedImage applyExtraLightEffect];
    UIView *walkthroughView = [[UIView alloc] initWithFrame:CGRectMake(0, rect.origin.y, walkthroughImage.size.width, walkthroughImage.size.height)];
    UIImageView *background = [[UIImageView alloc] initWithImage:croppedImage];
    [walkthroughView addSubview:background];
    
    UIImageView *foreground = [[UIImageView alloc] initWithImage:walkthroughImage];
    [walkthroughView addSubview:foreground];
    
    walkthroughView.backgroundColor = [UIColor clearColor];
    
    walkthroughView.alpha = 1.0;
    
    [self.viewController.view addSubview:walkthroughView];
    self.currentWalkthrough = walkthroughView;
    self.viewController.tableView.userInteractionEnabled = NO;
    [UIView animateWithDuration:1.0 animations:^{
        walkthroughView.alpha = 1.0;
    }];
}

- (void)completePredictWalkthrough {
    self.viewController.tableView.userInteractionEnabled = YES;
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:PredictWalkthroughCompleteKey];
    [self removeAllObservations];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.currentWalkthrough.alpha = 0.0;
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeAllObservations];
}

@end
