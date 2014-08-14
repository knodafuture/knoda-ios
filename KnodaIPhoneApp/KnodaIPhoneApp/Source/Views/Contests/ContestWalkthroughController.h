//
//  ContestWalkthroughController.h
//  KnodaIPhoneApp
//
//  Created by nick on 8/11/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "WalkthroughController.h"

UIKIT_EXTERN NSString *ContestVoteWalkthroughCompleteNotificationName;
UIKIT_EXTERN NSString *ContestVoteWalkthroughNotificationKey;
UIKIT_EXTERN NSString *ContestSuccessWalkthroughCompleteNotificationName;
UIKIT_EXTERN NSString *ContestSuccessWalkthroughNotificationKey;

@class ContestDetailsViewController;
@interface ContestWalkthroughController : WalkthroughController

- (id)initForContestDetailsViewController:(ContestDetailsViewController *)viewController;

@end
