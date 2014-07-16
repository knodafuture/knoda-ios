//
//  MeTableViewController.h
//  KnodaIPhoneApp
//
//  Created by nick on 7/16/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "PredictionsViewController.h"
#import "UserProfileHeaderView.h"

@class MeTableViewController;
@protocol MeTableViewControllerDelegate <UserProfileHeaderViewDelegate>

- (void)tableViewDidScroll:(UIScrollView *)scrollView inTableViewController:(MeTableViewController *)viewController;

@end

@interface MeTableViewController : PredictionsViewController

- (id)initForChallenged:(BOOL)challenged delegate:(id<MeTableViewControllerDelegate>)delegate;

- (void)setHeaderHidden:(BOOL)hidden;

@end
