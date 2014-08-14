//
//  ContestRankingsTableViewController.h
//  KnodaIPhoneApp
//
//  Created by nick on 8/4/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "RankingsTableViewController.h"
@class Contest;
@class ContestStage;
@interface ContestRankingsTableViewController : RankingsTableViewController
- (id)initWithContest:(Contest *)contest stage:(ContestStage *)stage;
@end
