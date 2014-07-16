//
//  MeViewController.m
//  KnodaIPhoneApp
//
//  Created by nick on 7/16/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "MeViewController.h"
#import "UserManager.h"
#import "SettingsViewController.h"
#import "UserProfileHeaderView.h"
#import "MeTableViewController.h"
#import "NavigationScrollView.h"

CGFloat const SwipeBezel = 30.0f;

@interface MeViewController () <UIScrollViewDelegate, MeTableViewControllerDelegate>
@property (weak, nonatomic) IBOutlet NavigationScrollView *scrollView;
@property (strong, nonatomic) UserProfileHeaderView *headerView;
@property (strong, nonatomic) NSArray *buttons;
@property (strong, nonatomic) NSArray *tableViewControllers;
@property (weak, nonatomic) MeTableViewController *visibleTableViewController;
@property (strong, nonatomic) UIView *selectionView;
@property (strong, nonatomic) UIView *buttonsContainer;
@property (assign, nonatomic) NSInteger activePage;
@property (assign, nonatomic) BOOL setup;
@end

@implementation MeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [UserManager sharedInstance].user.name;
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem rightBarButtonItemWithImage:[UIImage imageNamed:@"SettingsIcon"] target:self action:@selector(onSettings)];

    UILabel *myPredictionsLabel = [self headerLabel];
    myPredictionsLabel.text = @"My Predictions";
    
    UILabel *myVotesLabel = [self headerLabel];
    myVotesLabel.text = @"My Votes";
    
    self.buttons = @[myPredictionsLabel, myVotesLabel];
    
    MeTableViewController *myPredictions = [[MeTableViewController alloc] initForChallenged:NO delegate:self];
    MeTableViewController *myVotes = [[MeTableViewController alloc] initForChallenged:YES delegate:self];
    
    self.headerView = [[UserProfileHeaderView alloc] initWithDelegate:self];
    self.headerView.hidden = YES;
    [self.headerView populateWithUser:[UserManager sharedInstance].user];
    
    [self.view insertSubview:self.headerView atIndex:0];
    
    self.tableViewControllers = @[myPredictions, myVotes];
    
    self.selectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 36)];
    self.selectionView.backgroundColor = [UIColor colorFromHex:@"77bc1f"];
    
    self.scrollView.bezelWidth = SwipeBezel;
}

- (void)onSettings {
    SettingsViewController *vc = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:[NSBundle mainBundle]];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [[[[UIApplication sharedApplication] delegate] window].rootViewController presentViewController:nav animated:YES completion:nil];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.setup)
        return;
    
    self.setup = YES;
    
    for (int i = 0; i < self.tableViewControllers.count; i++){
        MeTableViewController *vc = self.tableViewControllers[i];
        CGRect frame = vc.view.frame;
        frame.size = self.scrollView.frame.size;
        frame.origin.y = 0;
        frame.origin.x = i * frame.size.width;
        vc.view.frame = frame;
        [self.scrollView addSubview:vc.view];
    }
    
    self.visibleTableViewController = self.tableViewControllers[0];
    
    [self.view addSubview:self.selectionView];
    
    CGRect frame = self.selectionView.frame;
    
    frame.origin.y = self.headerView.frame.size.height + self.visibleTableViewController.tableView.contentOffset.y;
    
    self.selectionView.frame = frame;
    
    if (self.buttons.count == 0)
        return;
    
    CGFloat totalTextWidth;
    
    for (UILabel *button in self.buttons) {
        [button sizeToFit];
        totalTextWidth = totalTextWidth + button.frame.size.width;
    }
    
    CGFloat width = self.view.frame.size.width - 80.0;
    CGFloat diff = width - totalTextWidth;
    diff = diff / 3;
    
    frame = self.selectionView.bounds;
    
    frame.size.width = width;
    frame.origin.x = (self.selectionView.frame.size.width / 2.0) - (frame.size.width / 2.0);
    
    self.buttonsContainer = [[UIView alloc] initWithFrame:frame];
    
    CGFloat currentOffset = 0;
    
    for (int i = 0; i < self.buttons.count; i++) {
        UILabel *button = self.buttons[i];
        
        frame = button.frame;
        frame.size.width = frame.size.width + diff;
        frame.origin.x = currentOffset;
        frame.size.height = self.selectionView.frame.size.height;
        currentOffset = currentOffset + frame.size.width;
        
        [self.buttonsContainer addSubview:button];
        button.frame = frame;
    }
    
    UILabel *lastButton = [self.buttons lastObject];
    
    if (lastButton.frame.origin.x + lastButton.frame.size.width != self.buttonsContainer.frame.size.width) {
        CGRect frame = lastButton.frame;
        frame.origin.x = self.buttonsContainer.frame.size.width - frame.size.width;
        lastButton.frame = frame;
    }
    
    [[self.buttons lastObject] setTextAlignment:NSTextAlignmentRight];
    
    [self.buttons[0] setAlpha:1.0];
    [self.selectionView addSubview:self.buttonsContainer];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width * self.tableViewControllers.count, self.view.frame.size.height);
}

- (void)tableViewDidScroll:(UIScrollView *)scrollView inTableViewController:(MeTableViewController *)viewController {
    if (viewController != self.visibleTableViewController)
        return;
    
    CGRect frame = self.selectionView.frame;
    
    frame.origin.y = MAX(self.headerView.frame.size.height - self.visibleTableViewController.tableView.contentOffset.y, 0);
    
    self.selectionView.frame = frame;
    
    for (MeTableViewController *vc in self.tableViewControllers) {
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
    for (MeTableViewController *vc in self.tableViewControllers) {
        [vc setHeaderHidden:YES];
    }
}

- (void)finishHeadersFromMove {
    CGFloat pageWidth = self.scrollView.frame.size.width;
    float fractionalPage = self.scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    
    self.visibleTableViewController = self.tableViewControllers[page];
    
    self.headerView.hidden = YES;
    
    for (MeTableViewController *vc in self.tableViewControllers) {
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
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.selectionView.frame.size.width * .25, self.selectionView.frame.size.height)];
    label.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
    label.textColor = [UIColor whiteColor];
    label.userInteractionEnabled = YES;
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentLeft;
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
    
    UILabel *current = [self.buttons objectAtIndex:self.activePage];
    UILabel *next = [self.buttons objectAtIndex:index];
    
    [UIView animateWithDuration:0.5 animations:^{
        current.alpha = 0.25;
        next.alpha = 1.0;
    }];
    
    self.activePage = index;
    
    self.visibleTableViewController = self.tableViewControllers[index];
}

@end
