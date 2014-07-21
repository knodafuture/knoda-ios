//
//  WalkthroughController.h
//  KnodaIPhoneApp
//
//  Created by nick on 7/17/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HomeViewController;
UIKIT_EXTERN NSString *VotingWalkthroughCompleteNotificationName;
UIKIT_EXTERN NSString *PredictWalkthroughCompleteNotificationName;
UIKIT_EXTERN NSString *VotingWalkthroughCompleteKey;
UIKIT_EXTERN NSString *PredictWalkthroughCompleteKey;
@interface WalkthroughController : NSObject


- (id)initWithTargetViewController:(HomeViewController *)viewController;
- (void)beginShowingWalkthroughIfNeeded;
@end
