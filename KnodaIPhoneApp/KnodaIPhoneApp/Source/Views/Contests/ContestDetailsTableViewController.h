//
//  ContestDetailsTableViewController.h
//  KnodaIPhoneApp
//
//  Created by nick on 8/3/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "PredictionsViewController.h"
#import "ContestTableViewCell.h"
@class Contest;
@class ContestDetailsTableViewController;

UIKIT_EXTERN NSString *ContestVotingEvent;

@protocol ContestDetailsTableViewControllerDelegate <ContestTableViewCellDelegate>

- (void)tableViewDidScroll:(UIScrollView *)scrollView inTableViewController:(ContestDetailsTableViewController *)viewController;
- (void)tableViewDidFinishLoadingInViewController:(ContestDetailsTableViewController *)viewController;

@end
@interface ContestDetailsTableViewController : PredictionsViewController

@property (strong, nonatomic) Contest *contest;

- (id)initForContest:(Contest *)contest expired:(BOOL)expired delegate:(id<ContestDetailsTableViewControllerDelegate>)delegate;
- (void)setHeaderHidden:(BOOL)hidden;
@end
