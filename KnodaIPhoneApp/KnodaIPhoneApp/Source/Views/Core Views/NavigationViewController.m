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
#import "AlertsViewController.h"

@interface NavigationViewController () <SelectPictureDelegate>

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
@end

@implementation NavigationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.itemNames = @[@"Home", @"History", @"Alerts", @"Badges", @"Profile"];
    self.masterShown = NO;
    self.vcCache = [[NSMutableDictionary alloc] init];
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    if (SYSTEM_VERSION_GREATER_THAN(@"7.0"))
        [self.menuItemsTableView setSeparatorInset:UIEdgeInsetsZero];
    
    UITapGestureRecognizer * recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(toggleNavigationPanel)];
    [self.gestureView addGestureRecognizer:recognizer];
    
    [self updateUserInfo];
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self observeProperty:@keypath(self.appDelegate.currentUser) withBlock:^(__weak id self, id old, id new) {
        [self updateUserInfo];
    }];
    
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.appeared) {
        self.appeared = YES;
    }
}

- (void)hackAnimationFinished {
    if(!self.appDelegate.currentUser.hasAvatar)
        [self showSelectPictureViewController];
    else
        [self openMenuItem: MenuHome];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self removeAllObservations];
}

- (void)openMenuItem:(MenuItem)menuItem {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:menuItem-1 inSection:0];
    [self.menuItemsTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];

    self.activeMenuItem = menuItem;
    [self presentViewControllerForMenuItem:menuItem];
}

- (UINavigationController *)navigationControllerForMenuItem:(MenuItem)menuItem {
    UIViewController *viewController = [self.vcCache objectForKey:@(menuItem)];
    if (!viewController) {
        switch (menuItem) {
            case MenuHome:
                viewController = [[HomeViewController alloc] initWithStyle:UITableViewStylePlain];
                break;
            case MenuAlerts:
                viewController = [[AlertsViewController alloc] initWithStyle:UITableViewStylePlain];
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
            default:
                viewController = [[HomeViewController alloc] initWithStyle:UITableViewStylePlain];
                break;
        }
        [self.vcCache setObject:viewController forKey:@(menuItem)];
    }
    
    return [[UINavigationController alloc] initWithRootViewController:viewController];
}

- (void)presentViewControllerForMenuItem:(MenuItem)menuItem {
    
    UINavigationController *vc = [self navigationControllerForMenuItem:menuItem];
    
    [self.childViewControllers makeObjectsPerformSelector:@selector(willMoveToParentViewController:)];
    [self.detailsView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [self.childViewControllers makeObjectsPerformSelector:@selector(removeFromParentViewController)];
    
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
    
    [[WebApi sharedInstance] getCurrentUser:^(User *user, NSError *error) {}];
    
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


- (AppDelegate *)appDelegate {
    return [UIApplication sharedApplication].delegate;
}

- (void)updateUserInfo {
    User * user = self.appDelegate.currentUser;
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setGroupingSeparator:[[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator]];
    
    self.pointsLabel.text = [NSString stringWithFormat:@"%@",[formatter stringFromNumber:[NSNumber numberWithInteger:user.points]]];
    self.wonLostLabel.text = [NSString stringWithFormat:@"%d-%d",user.won,user.lost];
    self.wonPercantageLabel.text = ![user.winningPercentage isEqual: @0] ? [NSString stringWithFormat:@"%@%@",user.winningPercentage,@"%"] : @"0%";
    self.steakLabel.text = [user.streak length] > 0 ? user.streak : @"W0";
    
    [self.menuItemsTableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return MenuItemsCount;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SideNavCell *cell = [SideNavCell sideNavCellForTableView:tableView];
    
    cell.icon.image = [UIImage imageNamed:[NSString stringWithFormat:@"SideNav%@Icon", self.itemNames[indexPath.row]]];
    
    if (indexPath.row == MenuProfile - 1)
        cell.titleLabel.text = self.appDelegate.currentUser.name;
    else
        cell.titleLabel.text = self.itemNames[indexPath.row];
    
    if (indexPath.row != MenuAlerts)
        cell.rightInfoLabel.hidden = YES;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self openMenuItem:indexPath.row+1];
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
    [self openMenuItem:MenuHome];
}

@end
