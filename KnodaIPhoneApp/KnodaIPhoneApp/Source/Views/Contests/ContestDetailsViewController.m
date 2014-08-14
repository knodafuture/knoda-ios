//
//  ContestDetailsViewController.m
//  KnodaIPhoneApp
//
//  Created by nick on 8/3/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "ContestDetailsViewController.h"
#import "NavigationScrollView.h"
#import "ContestDetailsTableViewController.h"
#import "ContestTableViewCell.h"
#import "WebViewController.h"   
#import "Contest.h" 
#import "WebApi.h"
#import "ContestWalkthroughController.h"
#import "LoadingView.h"
#import "ContestRankingsViewController.h"
#import "ContestRankingsTableViewController.h"

CGFloat const SwipeBezelll = 30.0f;

@interface ContestDetailsViewController () <ContestDetailsTableViewControllerDelegate>
@property (weak, nonatomic)
IBOutlet NavigationScrollView *scrollView;
@property (strong, nonatomic) NSArray *buttons;
@property (strong, nonatomic) NSArray *tableViewControllers;
@property (weak, nonatomic) ContestDetailsTableViewController *visibleTableViewController;
@property (strong, nonatomic) UIView *selectionView;
@property (strong, nonatomic) UIView *buttonsContainer;
@property (assign, nonatomic) NSInteger activePage;
@property (assign, nonatomic) BOOL setup;
@property (strong, nonatomic) Contest *contest;
@property (strong, nonatomic) ContestWalkthroughController *walkthroughController;
@end

@implementation ContestDetailsViewController

- (id)initWithContest:(Contest *)contest {
    self = [super initWithNibName:@"ContestDetailsViewController" bundle:[NSBundle mainBundle]];
    self.contest = contest;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"DETAILS";
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem rightBarButtonItemWithImage:[UIImage imageNamed:@"ContestInfoIcon"] target:self action:@selector(onInfo)];
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backButtonWithTarget:self action:@selector(back)];
    self.selectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 36)];
    self.selectionView.backgroundColor = [UIColor colorFromHex:@"77bc1f"];
    
    UILabel *livePredictionsLabel = [self headerLabel];
    livePredictionsLabel.text = @"Live Predictions";
    
    UILabel *expiredPredictionsLabel = [self headerLabel];
    expiredPredictionsLabel.text = @"Expired Predictions";
    
    self.buttons = @[livePredictionsLabel, expiredPredictionsLabel];
    
    ContestDetailsTableViewController *livePredictions = [[ContestDetailsTableViewController alloc] initForContest:self.contest expired:NO delegate:self];
    ContestDetailsTableViewController *expiredPredictions = [[ContestDetailsTableViewController alloc] initForContest:self.contest expired:YES delegate:self];
    
    self.headerView = [[ContestTableViewCell alloc] initWithContest:self.contest Delegate:self];
    self.headerView.hidden = YES;
    [[WebApi sharedInstance] getImage:self.contest.image.big completion:^(UIImage *image, NSError *error) {
        if (image)
            self.headerView.contestImageView.image = image;
    }];
    [self.view insertSubview:self.headerView atIndex:0];
    
    self.tableViewControllers = @[livePredictions, expiredPredictions];
    
    self.scrollView.bezelWidth = SwipeBezelll;
    
    self.scrollView.scrollsToTop = NO;
    
    self.walkthroughController = [[ContestWalkthroughController alloc] initForContestDetailsViewController:self];
    
    if (!self.contest.rank.integerValue)
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload) name:ContestVoteWalkthroughCompleteNotificationName object:nil];

}

- (void)reload {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ContestVoteWalkthroughCompleteNotificationName object:nil];
}

- (UITableView *)tableView {
    return self.visibleTableViewController.tableView;
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)onInfo {
    WebViewController *vc = [[WebViewController alloc] initWithURL:self.contest.detailsUrl];
    vc.title = @"CONTEST INFORMATION";
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.setup)
        return;
    
    self.setup = YES;
    
    for (int i = 0; i < self.tableViewControllers.count; i++){
        ContestDetailsTableViewController *vc = self.tableViewControllers[i];
        CGRect frame = vc.view.frame;
        frame.size = self.scrollView.frame.size;
        frame.origin.y = 0;
        frame.origin.x = i * frame.size.width;
        vc.view.frame = frame;
        [self addChildViewController:vc];
        [self.scrollView addSubview:vc.view];
    }
    
    self.visibleTableViewController = self.tableViewControllers[0];
    
    [self.view addSubview:self.selectionView];
    
    CGRect frame = self.selectionView.frame;
    
    frame.origin.y = self.headerView.frame.size.height + self.visibleTableViewController.tableView.contentOffset.y;
    
    self.selectionView.frame = frame;
    
    if (self.buttons.count == 0)
        return;
    
    UILabel *firstButton = self.buttons[0];
    UILabel *secondButton = self.buttons[1];
    
    frame = firstButton.frame;
    frame.origin.x = 0;
    frame.size.width = self.selectionView.frame.size.width / 2.0;
    firstButton.frame = frame;
    
    frame = secondButton.frame;
    frame.origin.x = self.selectionView.frame.size.width / 2.0;
    frame.size.width = frame.origin.x;
    secondButton.frame = frame;
    
    [self.selectionView addSubview:firstButton];
    [self.selectionView addSubview:secondButton];
    
    [self.buttons[0] setAlpha:1.0];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width * self.tableViewControllers.count, self.view.frame.size.height);
}

- (void)tableViewDidScroll:(UIScrollView *)scrollView inTableViewController:(ContestDetailsTableViewController *)viewController {

    if (viewController != self.visibleTableViewController)
        return;
    
    CGRect frame = self.selectionView.frame;
    
    frame.origin.y = MAX(self.headerView.frame.size.height - self.visibleTableViewController.tableView.contentOffset.y, 0);
    
    self.selectionView.frame = frame;
    
    for (ContestDetailsTableViewController *vc in self.tableViewControllers) {
        if (vc == self.visibleTableViewController)
            continue;
        vc.tableView.contentOffset = CGPointMake(0, MIN(self.headerView.frame.size.height, scrollView.contentOffset.y));
    }
}

- (void)prepareHeadersForMove {
    CGRect frame = self.headerView.frame;
    
    frame.origin.y = MAX(-self.headerView.frame.size.height / 2.0, -self.visibleTableViewController.tableView.contentOffset.y * 0.5);
    
    self.headerView.frame = frame;
    
    self.headerView.hidden = NO;
    for (ContestDetailsTableViewController *vc in self.tableViewControllers) {
        [vc setHeaderHidden:YES];
    }
}

- (void)finishHeadersFromMove {
    CGFloat pageWidth = self.scrollView.frame.size.width;
    float fractionalPage = self.scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    
    self.visibleTableViewController = self.tableViewControllers[page];
    
    self.headerView.hidden = YES;
    
    for (ContestDetailsTableViewController *vc in self.tableViewControllers) {
        [vc setHeaderHidden:NO];
    }
    
    [self selectIndex:page];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self prepareHeadersForMove];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self finishHeadersFromMove];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self finishHeadersFromMove];
}

- (UILabel *)headerLabel {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.selectionView.frame.size.width * .5, self.selectionView.frame.size.height)];
    label.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
    label.textColor = [UIColor whiteColor];
    label.userInteractionEnabled = YES;
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTapped:)];
    [label addGestureRecognizer:tap];
    label.alpha = 0.25;
    return label;
}

- (void)labelTapped:(UIGestureRecognizer *)sender {
    NSInteger index = [self.buttons indexOfObject:sender.view];
    UIViewController *vc = [self.tableViewControllers objectAtIndex:index];
    [self prepareHeadersForMove];
    
    
    [self.scrollView setContentOffset:CGPointMake(vc.view.frame.origin.x, 0) animated:YES];
    [self selectIndex:index];
}

- (void)selectIndex:(NSInteger)index {
    if (self.activePage == index)
        return;
    
    ContestDetailsTableViewController *previous = self.tableViewControllers[self.activePage];
    previous.tableView.scrollsToTop = NO;
    UILabel *current = [self.buttons objectAtIndex:self.activePage];
    UILabel *next = [self.buttons objectAtIndex:index];
    
    [UIView animateWithDuration:0.5 animations:^{
        current.alpha = 0.25;
        next.alpha = 1.0;
    }];
    
    self.activePage = index;
    
    self.visibleTableViewController = self.tableViewControllers[index];
    self.visibleTableViewController.tableView.scrollsToTop = YES;
}


- (CGRect)rectForFirstTableViewCell {
    UITableViewCell *cell = [self.visibleTableViewController.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    
    return cell.frame;
}

- (void)tableViewDidFinishLoadingInViewController:(ContestDetailsTableViewController *)viewController {
    if (viewController == self.visibleTableViewController)
        [self.walkthroughController beginShowingWalkthroughIfNeeded];
}

- (void)rankingsSelectedInTableViewCell:(ContestTableViewCell *)cell {
    
    if (cell.contest.contestStages.count > 0) {
        ContestRankingsViewController *vc = [[ContestRankingsViewController alloc] initWithContest:self.contest];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        ContestRankingsTableViewController *vc = [[ContestRankingsTableViewController alloc] initWithContest:self.contest stage:nil];
        vc.title = @"LEADERBOARD";
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
