//
//  RankingsViewController.m
//  KnodaIPhoneApp
//
//  Created by nick on 3/24/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "RankingsViewController.h"
#import "RankingsTableViewController.h"

@interface RankingsViewController () <UIScrollViewDelegate>
@property (strong, nonatomic) Group *group;
@property (strong, nonatomic) NSArray *rankingLists;
@property (strong, nonatomic) NSArray *buttons;
@property (assign, nonatomic) NSInteger activePage;
@end

@implementation RankingsViewController

- (id)initWithGroup:(Group *)group {
    self = [super initWithNibName:@"RankingsViewController" bundle:[NSBundle mainBundle]];
    self.group = group;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backButtonWithTarget:self action:@selector(back)];
    self.title = @"RANKINGS";
    RankingsTableViewController *weekly = [[RankingsTableViewController alloc] initWithGroup:self.group location:nil];
    RankingsTableViewController *monthly = [[RankingsTableViewController alloc] initWithGroup:self.group location:@"monthly"];
    RankingsTableViewController *allTime = [[RankingsTableViewController alloc] initWithGroup:self.group location:@"alltime"];
    self.rankingLists = @[weekly, monthly, allTime];
    
    UILabel *monthlyLabel = [self headerLabel];
    monthlyLabel.text = @"GROUP_LEADERBOARD_MONTHLY";
    [self.headerView addSubview:monthlyLabel];
    
    CGRect frame = monthlyLabel.frame;
    frame = monthlyLabel.frame;
    frame.origin.x = (self.headerView.frame.size.width / 2.0) - (frame.size.width / 2.0);
    monthlyLabel.frame = frame;
    
    UILabel *weeklyLabel = [self headerLabel];
    weeklyLabel.text = @"GROUP_LEADERBOARD_WEEKLY";
    [self.headerView addSubview:weeklyLabel];
    weeklyLabel.alpha = 1.0;
    
    frame.origin.x = monthlyLabel.frame.origin.x - frame.size.width;
    weeklyLabel.frame = frame;
    
    UILabel *allTimeLabel = [self headerLabel];
    allTimeLabel.text = @"GROUP_LEADERBOARD_ALLTIME";
    [self.headerView addSubview:allTimeLabel];
    
    frame = allTimeLabel.frame;
    frame.origin.x = monthlyLabel.frame.origin.x + monthlyLabel.frame.size.width;
    allTimeLabel.frame = frame;
    
    self.buttons = @[weeklyLabel, monthlyLabel, allTimeLabel];
    self.activePage = 0;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    for (int i =0; i < self.rankingLists.count; i++) {
        UIViewController *vc = [self.rankingLists objectAtIndex:i];
        CGRect frame = vc.view.frame;
        frame.origin.y = 0;
        frame.size.height = self.scrollView.frame.size.height;
        [self.scrollView addSubview:vc.view];
        frame.origin.x = self.scrollView.frame.size.width * i;
        vc.view.frame = frame;
    }
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * self.rankingLists.count, self.scrollView.frame.size.height);
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (UILabel *)headerLabel {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.headerView.frame.size.width * .25, self.headerView.frame.size.height)];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:11.0];
    label.textColor = [UIColor whiteColor];
    label.userInteractionEnabled = YES;
    label.textAlignment = NSTextAlignmentCenter;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTapped:)];
    [label addGestureRecognizer:tap];
    label.alpha = 0.25;
    return label;
}

- (void)selectIndex:(NSInteger)index {
    if (self.activePage == index)
        return;
    
    UILabel *current = [self.buttons objectAtIndex:self.activePage];
    UILabel *next = [self.buttons objectAtIndex:index];
    
    [UIView animateWithDuration:0.5 animations:^{
        current.alpha = 0.25;
        next.alpha = 1.0;
    }];
    
    self.activePage = index;
    NSString *event = [NSString stringWithFormat:@"%@", next.text];
    [Flurry logEvent:event];

}

- (void)labelTapped:(UIGestureRecognizer *)sender {
    
    NSInteger index = [self.buttons indexOfObject:sender.view];
    UIViewController *vc = [self.rankingLists objectAtIndex:index];
    [self.scrollView setContentOffset:CGPointMake(vc.view.frame.origin.x, 0) animated:YES];
    [self selectIndex:index];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat pageWidth = scrollView.frame.size.width;
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    [self selectIndex:page];
}
@end
