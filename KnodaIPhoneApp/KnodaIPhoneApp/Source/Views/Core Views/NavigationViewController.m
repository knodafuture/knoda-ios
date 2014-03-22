//
//  NavigationViewController.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/24/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "NavigationViewController.h"
#import "AppDelegate.h"
#import "SelectPictureViewController.h"
#import "LoadingView.h" 
#import "User+Utils.h"
#import "HomeViewController.h"
#import "ProfileViewController.h"
#import "HistoryViewController.h"
#import "BadgesCollectionViewController.h"
#import "SideNavCell.h"
#import "PredictionsViewController.h"
#import "ActivityViewController.h"
#import "SideNavBarButtonItem.h"
#import "AddPredictionViewController.h"
#import "RightSideButtonsView.h"
#import <QuartzCore/QuartzCore.h>
#import "SearchViewController.h"
#import "UserManager.h"
#import "GroupsViewController.h"

@interface NavigationViewController () <SearchViewControllerDelegate, SelectPictureDelegate, AddPredictionViewControllerDelegate, UINavigationControllerDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UILabel *pointsLabel;
@property (weak, nonatomic) IBOutlet UILabel *wonLostLabel;
@property (weak, nonatomic) IBOutlet UILabel *wonPercantageLabel;
@property (weak, nonatomic) IBOutlet UILabel *steakLabel;
@property (weak, nonatomic) IBOutlet UIView *masterView;
@property (weak, nonatomic) IBOutlet UIView *detailsView;
@property (weak, nonatomic) IBOutlet UIView *movingView;
@property (weak, nonatomic) IBOutlet UITableView *menuItemsTableView;
@property (weak, nonatomic) IBOutlet UIView *gestureView;

@property (assign, nonatomic) BOOL appeared;
@property (assign, nonatomic) BOOL masterShown;
@property (assign, nonatomic) MenuItem activeMenuItem;
@property (strong, nonatomic) NSArray *itemNames;
@property (strong, nonatomic) SelectPictureViewController *selectVc;
@property (readonly, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) NSMutableDictionary *vcCache;

@property (strong, nonatomic) SideNavBarButtonItem *sideNavBarButtonItem;
@property (strong, nonatomic) RightSideButtonsView *rightSideBarButtonsView;
@property (strong, nonatomic) UIBarButtonItem *rightSideBarButtonItem;

@property (strong, nonatomic) NSTimer *pingTimer;
@property (weak, nonatomic) UINavigationController *topNavigationController;

@property (assign, nonatomic) MenuItem firstMenuItem;
@property (readonly, nonatomic) UserManager *userManger;

@end

@implementation NavigationViewController


- (id)initWithFirstMenuItem:(MenuItem)menuItem {
    self = [super initWithNibName:@"NavigationViewController" bundle:[NSBundle mainBundle]];
    self.itemNames = @[@"Home", @"Activity", @"Groups", @"History",  @"Badges", @"Profile"];
    self.masterShown = NO;
    self.vcCache = [[NSMutableDictionary alloc] init];
    self.firstMenuItem = MenuGroups;
    _userManger = [UserManager sharedInstance];
    return self;
    
}
- (void) viewDidLoad {
    [super viewDidLoad];
    
    if (SYSTEM_VERSION_GREATER_THAN(@"7.0"))
        [self.menuItemsTableView setSeparatorInset:UIEdgeInsetsZero];
    
    UITapGestureRecognizer * recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(toggleNavigationPanel)];
    [self.gestureView addGestureRecognizer:recognizer];
    
    [self updateUserInfo];
    self.sideNavBarButtonItem = [[SideNavBarButtonItem alloc] initWithTarget:self action:@selector(toggleNavigationPanel)];
    
    self.rightSideBarButtonsView = [[RightSideButtonsView alloc] init];
    
    [self.rightSideBarButtonsView setSearchTarget:self action:@selector(search)];
    [self.rightSideBarButtonsView setAddPredictionTarget:self action:@selector(presentAddPredictionViewController)];
    
    self.rightSideBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightSideBarButtonsView];
    
    [self updateAlerts];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self observeNotification:UserChangedNotificationName withBlock:^(__weak id self, NSNotification *notification) {
        [self updateUserInfo];
    }];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.pingTimer invalidate];
    self.pingTimer = nil;
    
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.appeared) {
        self.appeared = YES;
    }
    
    [self.pingTimer invalidate];
    self.pingTimer = nil;
    self.pingTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(serverPing) userInfo:nil repeats:YES];
    
}

- (void)serverPing {
    [self updateAlerts];
}
- (void)hackAnimationFinished {
    if(![UserManager sharedInstance].user.hasAvatar)
        [self showSelectPictureViewController];
    else
        [self openMenuItem: self.firstMenuItem];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self removeAllObservations];
}

- (void)openMenuItem:(MenuItem)menuItem {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:menuItem inSection:0];
    [self.menuItemsTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];

    self.activeMenuItem = menuItem;
    [self presentViewControllerForMenuItem:menuItem];
    
    if (menuItem == MenuAlerts) {
        SideNavCell *cell = (SideNavCell *)[self.menuItemsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:MenuAlerts - 1 inSection:0]];
        cell.rightInfoLabel.hidden = YES;
        [self.sideNavBarButtonItem setAlertsCount:0];
    }
}

- (UINavigationController *)navigationControllerForMenuItem:(MenuItem)menuItem {
    UIViewController *viewController = [self.vcCache objectForKey:@(menuItem)];
    if (!viewController) {
        switch (menuItem) {
            case MenuHome:
                viewController = [[HomeViewController alloc] initWithStyle:UITableViewStylePlain];
                break;
            case MenuAlerts:
                viewController = [[ActivityViewController alloc] initWithStyle:UITableViewStylePlain];
                break;
            case MenuBadges:
                viewController = [[BadgesCollectionViewController alloc] initWithNibName:@"BadgesCollectionViewController" bundle:[NSBundle mainBundle]];
                break;
            case MenuHistory:
                viewController = [[HistoryViewController alloc] initWithStyle:UITableViewStylePlain];
                break;
            case MenuProfile:
                viewController = [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:[NSBundle mainBundle]];
                break;
            case MenuGroups:
                viewController = [[GroupsViewController alloc] initWithStyle:UITableViewStylePlain];
                break;
            default:
                viewController = [[HomeViewController alloc] initWithStyle:UITableViewStylePlain];
                break;
        }

        [self.vcCache setObject:viewController forKey:@(menuItem)];
    }
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    navigationController.delegate = self;
    viewController.navigationItem.leftBarButtonItem = self.sideNavBarButtonItem;

    self.topNavigationController = navigationController;
    
    return navigationController;
}

- (void)presentViewControllerForMenuItem:(MenuItem)menuItem {
    
    UINavigationController *vc = [self navigationControllerForMenuItem:menuItem];
    
    [self.detailsView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.childViewControllers makeObjectsPerformSelector:@selector(willMoveToParentViewController:) withObject:nil];
    [self.childViewControllers makeObjectsPerformSelector:@selector(removeFromParentViewController)];
    
    [vc willMoveToParentViewController:self];
    [self addChildViewController:vc];
    
    vc.view.frame = self.detailsView.bounds;

    [self.detailsView addSubview:vc.view];

    [vc didMoveToParentViewController:self];
    
    [self moveToDetailsAnimated:self.appeared];
}

- (void)moveToDetailsAnimated: (BOOL) animated {
    
    if (!self.masterShown)
        return;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:animated];

    if (animated)
        [UIView animateWithDuration:0.3 animations:^{
             [self moveToDetails];
         }];
    else
        [self moveToDetails];
}


- (void)moveToDetails {
    [Flurry endTimedEvent: @"Navigation_Screen" withParameters: nil];
    
    self.masterShown = NO;
    self.gestureView.hidden = YES;
    
    CGRect newFrame = self.movingView.frame;
    newFrame.origin.x -= self.masterView.frame.size.width;
    self.movingView.frame = newFrame;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        [[self appDelegate] window].backgroundColor = [UIColor colorFromHex:@"77BC1F"];
    }

}

- (void)moveToMasterAnimated:(BOOL)animated {
    if (animated)
        [UIView animateWithDuration:0.3 animations:^{
            [self moveToMaster];
        }];
    else
        [self moveToMaster];
}

- (void)moveToMaster {
    [Flurry logEvent: @"Navigation_Screen" withParameters: nil timed: YES];
        
    self.masterShown = YES;
    self.gestureView.hidden = NO;
    
    [[UserManager sharedInstance] refreshUser:^(User *user, NSError *error) {}];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    
     CGRect newFrame = self.movingView.frame;
     newFrame.origin.x += self.masterView.frame.size.width;
     self.movingView.frame = newFrame;
     if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
         [[self appDelegate] window].backgroundColor = [UIColor blackColor];
    
}


- (void)toggleNavigationPanel
{
    if (self.masterShown)
        [self moveToDetailsAnimated: YES];
    else {
        self.gestureView.hidden = NO;
        [self moveToMasterAnimated:YES];
    }
}

- (void) animatedMoveToDetailsWithGestureRecognizer : (UITapGestureRecognizer *) recognizer {
    [self moveToDetailsAnimated:YES];
}

- (void)updateAlerts {
    [[WebApi sharedInstance] getUnseenActivity:^(NSArray *alerts, NSError *error) {
        if (error)
            return;
        
        SideNavCell *cell = (SideNavCell *)[self.menuItemsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:MenuAlerts - 1 inSection:0]];
        if (alerts.count) {
            cell.rightInfoLabel.hidden = NO;
            cell.rightInfoLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)alerts.count];
        }
        else
            cell.rightInfoLabel.hidden = YES;
        
        [self.sideNavBarButtonItem setAlertsCount:alerts.count];
        
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:alerts.count];
        
    }];
}

- (AppDelegate *)appDelegate {
    return [UIApplication sharedApplication].delegate;
}

- (void)updateUserInfo {
    User * user = [UserManager sharedInstance].user;
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setGroupingSeparator:[[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator]];
    
    self.pointsLabel.text = [NSString stringWithFormat:@"%@",[formatter stringFromNumber:[NSNumber numberWithInteger:user.points]]];
    self.wonLostLabel.text = [NSString stringWithFormat:@"%lu-%lu",(unsigned long)user.won,(unsigned long)
                              user.lost];
    if ([user.winningPercentage isEqual:@0])
        self.wonPercantageLabel.text = @"0%";
    else if ([user.winningPercentage isEqual:@100])
        self.wonPercantageLabel.text = @"100%";
    else
        self.wonPercantageLabel.text = [NSString stringWithFormat:@"%@%@",user.winningPercentage,@"%"];
    self.steakLabel.text = [user.streak length] > 0 ? user.streak : @"W0";
    
    SideNavCell *cell = (SideNavCell *)[self.menuItemsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:MenuProfile-1 inSection:0]];
    cell.titleLabel.text = user.name;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return MenuItemsCount;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SideNavCell *cell = [SideNavCell sideNavCellForTableView:tableView];
    
    cell.icon.image = [UIImage imageNamed:[NSString stringWithFormat:@"SideNav%@Icon", self.itemNames[indexPath.row]]];
    
    if (indexPath.row == MenuProfile)
        cell.titleLabel.text = [UserManager sharedInstance].user.name;
    else
        cell.titleLabel.text = self.itemNames[indexPath.row];
    
    if (indexPath.row != MenuAlerts)
        cell.rightInfoLabel.hidden = YES;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self openMenuItem:indexPath.row];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    if (![viewController isKindOfClass:SearchViewController.class])
        viewController.navigationItem.rightBarButtonItem = self.rightSideBarButtonItem;
}

#pragma mark SelectPictureDelegate

- (void)showSelectPictureViewController {
    self.selectVc = [[SelectPictureViewController alloc] initWithNibName:@"SelectPictureViewController" bundle:[NSBundle mainBundle]];
    self.selectVc.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self.selectVc];
    
    [self presentViewController:nav animated:YES completion:nil];
}
- (void)hideViewController:(SelectPictureViewController *)vc {
    [[LoadingView sharedInstance] hide];
    [[WebApi sharedInstance] checkNewBadges];
    [self openMenuItem:self.firstMenuItem];
}


- (void)presentAddPredictionViewController {
    AddPredictionViewController *vc = [[AddPredictionViewController alloc] initWithNibName:@"AddPredictionViewController" bundle:[NSBundle mainBundle]];
    vc.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)addPredictionViewController:(AddPredictionViewController *)viewController didCreatePrediction:(Prediction *)prediction {
    [[NSNotificationCenter defaultCenter] postNotificationName:NewObjectNotification object:nil userInfo:@{NewPredictionNotificationKey: prediction}];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [[WebApi sharedInstance] checkNewBadges];
    }];
}

- (void)search {
    SearchViewController *vc = [[SearchViewController alloc] initWithStyle:UITableViewStylePlain];
    vc.delegate = self;
    [self.rightSideBarButtonsView setSearchButtonHidden:YES];
    [self.topNavigationController pushViewController:vc animated:YES];
}

- (void)searchViewControllerDidFinish:(SearchViewController *)searchViewController {
    [self.rightSideBarButtonsView setSearchButtonHidden:NO];
}

- (void)dealloc {
    [self removeAllObservations];
}

@end
