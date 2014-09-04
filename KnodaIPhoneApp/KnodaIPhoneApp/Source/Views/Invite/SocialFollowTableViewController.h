//
//  SocialFollowTableViewController.h
//  KnodaIPhoneApp
//
//  Created by nick on 8/23/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "BaseTableViewController.h"

@class SocialFollowTableViewController;

@protocol SocialFollowTableViewControllerDelegate <NSObject>

- (void)selectionUpdatedInViewController:(SocialFollowTableViewController *)viewController;

@end

@interface SocialFollowTableViewController : BaseTableViewController
@property (weak, nonatomic) id<SocialFollowTableViewControllerDelegate> delegate;
@property (readonly, nonatomic) NSArray *selectedMatches;
@property (readonly, nonatomic) NSArray *invitations;

- (id)initForProvider:(NSString *)provider delegate:(id<SocialFollowTableViewControllerDelegate>)delegate;


@end
