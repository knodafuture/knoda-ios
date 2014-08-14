//
//  ContestRankingsViewController.m
//  KnodaIPhoneApp
//
//  Created by nick on 8/4/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "ContestRankingsViewController.h"
#import "ContestRankingsTableViewController.h"
#import "Contest.h"
#import "ContestStage.h"

@interface ContestRankingsViewController ()
@property (strong, nonatomic) Contest *contest;
@end

@implementation ContestRankingsViewController

- (id)initWithContest:(Contest *)contest {
    self = [super init];
    
    self.contest = contest;
    return self;
}

- (void)setupViews {
    ContestRankingsTableViewController *overall = [[ContestRankingsTableViewController alloc] initWithContest:self.contest stage:nil];
    [self addViewController:overall title:@"OVERALL"];
    for (ContestStage *stage in self.contest.contestStages) {
        ContestRankingsTableViewController *vc = [[ContestRankingsTableViewController alloc] initWithContest:self.contest stage:stage];
        [self addViewController:vc title:stage.name.uppercaseString];
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"LEADERBOARD";
    

    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backButtonWithTarget:self action:@selector(back)];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
