//
//  ContestTableViewCell.m
//  KnodaIPhoneApp
//
//  Created by nick on 8/1/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "ContestTableViewCell.h"
#import "Contest.h"
#import "NSNumber+Utils.h"  
#import "Leader.h"

static UINib *nib;

@implementation ContestTableViewCell

+ (void)initialize {
    nib = [UINib nibWithNibName:@"ContestTableViewCell" bundle:[NSBundle mainBundle]];
}

+ (ContestTableViewCell *)cellForTableView:(UITableView *)tableView {
    
    ContestTableViewCell *cell = nil;//[tableView dequeueReusableCellWithIdentifier:@"contestCell"];
    
    if (!cell) {
        cell = [[nib instantiateWithOwner:nil options:nil] lastObject];
        
        cell.contestImageView.layer.cornerRadius = cell.contestImageView.frame.size.width / 2.0;
        cell.contestImageView.clipsToBounds = YES;
        
        
        cell.contestImageView.layer.borderColor = [UIColor colorFromHex:@"efefef"].CGColor;
        cell.contestImageView.layer.borderWidth = 1.0;
    }
    
    return cell;
}

+ (CGFloat)heightForContest:(Contest *)contest {
    if (contest.image)
        return 165;
    else
        return 165 - 46;
}

- (void)populateWithContest:(Contest *)contest explore:(BOOL)explore {
    
    self.contest = contest;
    [self populateUI:contest];
    
    self.leaderInfoView.hidden = !explore;

    self.viewPredictionsView.hidden = explore;
    self.exploreInfoView.hidden = YES;
    
    self.rankingsArrow.hidden = !self.contest.rank.integerValue;
    
}

- (void)populateUI:(Contest *)contest {
    self.descriptionLabel.text = contest.description;
    self.rankLabel.text = [contest.rank ordinalString];
    self.overallLabel.text = [NSString stringWithFormat:@"overall (%ld)", (long)contest.participants.integerValue];
    
    self.nameLabel.text = contest.name;
    self.leaderNameLabel.text = contest.leader.username;
    self.exploreLeaderLabel.text = contest.leader.username;
    self.exploreRankLabel.text = [NSString stringWithFormat:@"%ld", (long)contest.participants.integerValue];
    if (!contest.image) {
        CGFloat heightDiff = self.contestImageView.frame.origin.y + self.contestImageView.frame.size.width;
        
        CGRect frame = self.nameLabel.frame;
        frame.origin.y -= heightDiff;
        self.nameLabel.frame = frame;
        
        frame = self.descriptionLabel.frame;
        frame.origin.y -= heightDiff;
        self.descriptionLabel.frame = frame;
        
        frame = self.frame;
        frame.size.height -= heightDiff;
        self.frame = frame;
        
        self.contestImageView.hidden = YES;
    }
}

- (id)initWithContest:(Contest *)contest Delegate:(id<ContestTableViewCellDelegate>)delegate {
    self = [[nib instantiateWithOwner:nil options:nil] lastObject];
    self.contestImageView.layer.cornerRadius = self.contestImageView.frame.size.width / 2.0;
    self.contestImageView.clipsToBounds = YES;
    
    
    self.contestImageView.layer.borderColor = [UIColor colorFromHex:@"efefef"].CGColor;
    self.contestImageView.layer.borderWidth = 1.0;
    self.delegate = delegate;
    self.contest = contest;
    
    self.viewPredictionsView.hidden = YES;
    
    
    if (contest.rank.integerValue) {
        self.exploreInfoView.hidden = YES;
        self.leaderInfoView.hidden = NO;
        self.rankingsArrow.hidden = NO;
    }else {
        self.leaderInfoView.hidden = YES;
        self.exploreInfoView.hidden = NO;
        self.rankingsArrow.hidden = NO;
    }
    
    CGSize beforeSize = self.descriptionLabel.frame.size;
    self.descriptionLabel.numberOfLines = 0;
    [self populateUI:contest];
    [self.descriptionLabel sizeToFit];
    
    
    self.seperatorView.hidden = YES;
    CGRect frame = self.frame;
    
    frame.size.height += self.descriptionLabel.frame.size.height - beforeSize.height;
    
    frame.size.height -= self.seperatorView.frame.size.height;
    
    self.frame = frame;
    
    frame = self.leaderInfoView.frame;
    frame.origin.y += self.seperatorView.frame.size.height;
    self.leaderInfoView.frame = frame;
    self.exploreInfoView.frame = frame;
    self.viewPredictionsView.frame = frame;
    
    return self;
}

- (IBAction)rankingsSelected:(id)sender {
    [self.delegate rankingsSelectedInTableViewCell:self];
}

@end
