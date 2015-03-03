//
//  WalkthroughController.h
//  KnodaIPhoneApp
//
//  Created by nick on 7/17/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HomeViewController;
@class AddPredictionViewController;
@class GenericWalkthroughView;
UIKIT_EXTERN NSString *VotingWalkthroughCompleteNotificationName;
UIKIT_EXTERN NSString *PredictWalkthroughCompleteNotificationName;
UIKIT_EXTERN NSString *VotingDateWalkthroughCompleteNotificationName;
UIKIT_EXTERN NSString *VotingWalkthroughCompleteKey;
UIKIT_EXTERN NSString *PredictWalkthroughCompleteKey;
UIKIT_EXTERN NSString *VotingDateWalkthroughCompleteKey;

@interface WalkthroughController : NSObject
@property (strong, nonatomic) id currentWalkthrough;

- (id)initWithTargetViewController:(HomeViewController *)viewController;
- (id)initForAddPredictionViewController:(AddPredictionViewController *)viewController;

- (void)beginShowingWalkthroughIfNeeded;
@end
