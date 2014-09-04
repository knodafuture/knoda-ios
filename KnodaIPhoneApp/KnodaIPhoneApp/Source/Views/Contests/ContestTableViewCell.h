//
//  ContestTableViewCell.h
//  KnodaIPhoneApp
//
//  Created by nick on 8/1/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Contest;
@class ContestTableViewCell;

@protocol ContestTableViewCellDelegate <NSObject>

- (void)rankingsSelectedInTableViewCell:(ContestTableViewCell *)cell;
@end

@interface ContestTableViewCell : UITableViewCell

@property (strong, nonatomic) Contest *contest;

@property (weak, nonatomic) IBOutlet UIImageView *contestImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *rankLabel;
@property (weak, nonatomic) IBOutlet UILabel *overallLabel;
@property (weak, nonatomic) IBOutlet UILabel *leaderNameLabel;

@property (weak, nonatomic) IBOutlet UIView *viewPredictionsView;
@property (weak, nonatomic) IBOutlet UIView *leaderInfoView;
@property (weak, nonatomic) IBOutlet UIView *exploreInfoView;
@property (weak, nonatomic) IBOutlet UILabel *exploreRankLabel;
@property (weak, nonatomic) IBOutlet UILabel *exploreLeaderLabel;
@property (weak, nonatomic) IBOutlet UIView *seperatorView;
@property (weak, nonatomic) IBOutlet UIImageView *rankingsArrow;
@property (weak, nonatomic) IBOutlet UIImageView *rankingsArrow2;
@property (weak, nonatomic) id<ContestTableViewCellDelegate> delegate;

- (id)initWithContest:(Contest *)contest Delegate:(id<ContestTableViewCellDelegate>)delegate;

+ (ContestTableViewCell *)cellForTableView:(UITableView *)tableView;
+ (CGFloat)heightForContest:(Contest *)contest;
- (void)populateWithContest:(Contest *)contest explore:(BOOL)explore;
- (IBAction)rankingsSelected:(id)sender;
@end
