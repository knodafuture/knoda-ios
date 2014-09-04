//
//  SingleContestRankingsViewController.m
//  KnodaIPhoneApp
//
//  Created by nick on 9/3/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "SingleContestRankingsViewController.h"
#import "ContestRankingsTableViewController.h"

@interface SingleContestRankingsViewController ()
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) Contest *contest;
@property (strong, nonatomic) ContestRankingsTableViewController *vc;
@end

@implementation SingleContestRankingsViewController


- (id)initWithContest:(Contest *)contest {
    self = [super initWithNibName:@"SingleContestsRankingsContainerView" bundle:[NSBundle mainBundle]];
    self.contest = contest;
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"LEADERBOARD";
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backButtonWithTarget:self action:@selector(back)];

}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)viewDidAppear:(BOOL)animated {
    self.vc = [[ContestRankingsTableViewController alloc] initWithContest:self.contest stage:nil];
    CGRect frame = self.vc.view.frame;
    frame.size.height = self.view.frame.size.height - (self.headerView.frame.origin.y + self.headerView.frame.size.height);
    frame.origin.y = self.headerView.frame.size.height;
    self.vc.view.frame = frame;
    
    [self.view addSubview:self.vc.view];
}


@end
