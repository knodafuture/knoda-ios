//
//  ContestRankingsTableViewController.m
//  KnodaIPhoneApp
//
//  Created by nick on 8/4/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "ContestRankingsTableViewController.h"
#import "WebApi.h"
#import "ContestStage.h"

@interface ContestRankingsTableViewController ()
@property (strong, nonatomic) Contest *contest;
@property (strong, nonatomic) ContestStage *stage;
@end

@implementation ContestRankingsTableViewController

- (id)initWithContest:(Contest *)contest stage:(ContestStage *)stage {
    self = [super init];
    self.contest = contest;
    self.stage = stage;
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backButtonWithTarget:self action:@selector(back)];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)refresh {
    [[WebApi sharedInstance] getLeaderBoardForContest:self.contest.contestId.integerValue stage:self.stage.contestStageId.integerValue completion:^(NSArray *leaders, NSError *error) {
        if (!error)
            self.leaders = leaders;
        [self.tableView reloadData];
    }];
}

@end
