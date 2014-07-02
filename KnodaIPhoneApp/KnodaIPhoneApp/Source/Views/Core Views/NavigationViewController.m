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
#import "SideNavBarButtonItem.h"
#import "AddPredictionViewController.h"
#import "RightSideButtonsView.h"
#import <QuartzCore/QuartzCore.h>
#import "SearchViewController.h"
#import "UserManager.h"
#import "GroupsViewController.h"
#import "NavigationScrollView.h"
#import "GroupSettingsViewController.h"
#import "NotificationSettingsViewController.h"
#import "NewActivityViewController.h"

CGFloat const SideNavBezelWidth = 20.0f;

@interface NavigationViewController () <UIScrollViewDelegate, SearchViewControllerDelegate, SelectPictureDelegate, AddPredictionViewControllerDelegate, UINavigationControllerDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UILabel *pointsLabel;
@property (weak, nonatomic) IBOutlet UILabel *wonLostLabel;
@property (weak, nonatomic) IBOutlet UILabel *wonPercantageLabel;
@property (weak, nonatomic) IBOutlet UILabel *steakLabel;
@property (weak, nonatomic) IBOutlet UITableView *menuItemsTableView;
@property (assign, nonatomic) BOOL sideNavVisible;
@property (weak, nonatomic) IBOutlet NavigationScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *sideNavView;

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
@property (strong, nonatomic) UINavigationController *visibleViewController;

@property (readonly, nonatomic) UserManager *userManger;

@property (strong, nonatomic) Group *activeGroup;

@property (strong, nonatomic) NSDictionary *pushInfo;
@end

@implementation NavigationViewController

- (id)initWithPushInfo:(NSDictionary *)pushInfo {
    self = [super initWithNibName:@"NavigationViewController" bundle:[NSBundle mainBundle]];
    self.itemNames = @[@"Home", @"Activity", @"Groups", @"History",  @"Badges", @"Profile"];
    self.masterShown = NO;
    self.vcCache = [[NSMutableDictionary alloc] init];
    self.pushInfo = pushInfo;
    _userManger = [UserManager sharedInstance];
    return self;
    
}
- (void) viewDidLoad {
    [super viewDidLoad];
    
    if (SYSTEM_VERSION_GREATER_THAN(@"7.0"))
        [self.menuItemsTableView setSeparatorInset:UIEdgeInsetsZero];
    
    [self updateUserInfo];
    self.sideNavBarButtonItem = [[SideNavBarButtonItem alloc] initWithTarget:self action:@selector(toggleSideNav)];
    
    self.rightSideBarButtonsView = [[RightSideButtonsView alloc] init];
    
    
    [self.rightSideBarButtonsView setSearchTarget:self action:@selector(search)];
    [self.rightSideBarButtonsView setAddPredictionTarget:self action:@selector(presentAddPredictionViewController)];
    
    self.rightSideBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightSideBarButtonsView];
    
    [self updateAlerts];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activeGroupChanged:) name:ActiveGroupChangedNotificationName object:nil];
    
	self.scrollView.bezelWidth = SideNavBezelWidth;
	self.scrollView.contentSize = CGSizeMake(self.sideNavView.frame.size.width + self.scrollView.frame.size.width, 0);
	self.scrollView.contentOffset = CGPointMake(self.sideNavView.frame.size.width, 0);
    
    
}

- (void)handleOpenUrl:(NSURL *)url {
    
    NSString *host = [url host];
    if ([[url scheme] isEqualToString:@"knoda"]) {
    
        if ([host isEqualToString:@"predictions"]) {
            [self showPrediction:[[[url pathComponents] lastObject] integerValue]];
        }
    } else {
        NSRange locationOfShare = [url.path rangeOfString:@"/share"];
        if (locationOfShare.location == NSNotFound)
            return;
        NSString *newUrl = [NSString stringWithFormat:@"knoda:/%@", [url.path substringToIndex:[url.path rangeOfString:@"/share"].location]];
        [self handleOpenUrl:[NSURL URLWithString:newUrl]];
    }
}

- (void)handlePushInfo:(NSDictionary *)pushInfo {
    self.pushInfo = pushInfo;
    if (self.pushInfo) {
        if ([self.pushInfo[@"type"] isEqualToString:@"p"]) {
            [self showPrediction:[self.pushInfo[@"id"] integerValue]];
        } else if ([self.pushInfo[@"type"] isEqualToString:@"gic"]) {
            [self showInvite:[self.pushInfo[@"id"] stringValue]];
        }
    }
    
}

- (void)showInvite:(NSString *)inviteId {
    [[LoadingView sharedInstance] show];
    [[WebApi sharedInstance] getInvitationDetails:inviteId completion:^(InvitationCodeDetails *details, NSError *error) {
        [[LoadingView sharedInstance] hide];
        if (!error) {
            [self openMenuItem:MenuAlerts];
            GroupSettingsViewController *vc = [[GroupSettingsViewController alloc] initWithGroup:details.group invitationCode:inviteId];
            [self.visibleViewController pushViewController:vc animated:YES];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"An unknown error occured." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
    }];
}

- (void)showPrediction:(NSInteger)predictionId {
    [[LoadingView sharedInstance] show];
    [[WebApi sharedInstance] getPrediction:predictionId completion:^(Prediction *prediction, NSError *error) {
        [[LoadingView sharedInstance] hide];
        if (error)
            return;
        [self openMenuItem:MenuAlerts];
        PredictionDetailsViewController *vc = [[PredictionDetailsViewController alloc] initWithPrediction:prediction];
        [self.visibleViewController pushViewController:vc animated:YES];
    }];
}

- (void)activeGroupChanged:(NSNotification *)notification {
    Group *newGroup = [notification.userInfo objectForKey:ActiveGroupNotificationKey];
    if (newGroup)
        self.activeGroup = newGroup;
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
    else {
        self.sideNavView.hidden = NO;
        [self openMenuItem:MenuHome];
        if (self.launchUrl) {
            [self handleOpenUrl:self.launchUrl];
        }
        [self handlePushInfo:self.pushInfo];
    }
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

- (void)presentViewControllerForMenuItem:(MenuItem)menuItem {
    UINavigationController *controller = [self navigationControllerForMenuItem:menuItem];
    [self showViewController:controller];
}

- (UINavigationController *)navigationControllerForMenuItem:(MenuItem)menuItem {
    UIViewController *viewController = [self.vcCache objectForKey:@(menuItem)];
    if (!viewController) {
        switch (menuItem) {
            case MenuHome:
                viewController = [[HomeViewController alloc] initWithStyle:UITableViewStylePlain];
                break;
            case MenuAlerts:
                viewController = [[NewActivityViewController alloc] init];
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
    
    if (menuItem != MenuGroups)
        self.activeGroup = nil;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    navigationController.delegate = self;
    viewController.navigationItem.leftBarButtonItem = self.sideNavBarButtonItem;
    
    return navigationController;
}

- (void)updateAlerts {
    [[WebApi sharedInstance] getUnseenActivity:^(NSArray *alerts, NSError *error) {
        if (error)
            return;
        
        SideNavCell *cell = (SideNavCell *)[self.menuItemsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:MenuAlerts inSection:0]];
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
    
    SideNavCell *cell = (SideNavCell *)[self.menuItemsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:MenuProfile inSection:0]];
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
    
    if (![viewController isKindOfClass:SearchViewController.class] && ![viewController isKindOfClass:NotificationSettingsViewController.class])
        viewController.navigationItem.rightBarButtonItem = self.rightSideBarButtonItem;
}

#pragma mark SelectPictureDelegate

- (void)showSelectPictureViewController {
    self.selectVc = [[SelectPictureViewController alloc] initWithBaseDefaultImageName:@"avatar"];
    self.selectVc.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self.selectVc];
    
    [self presentViewController:nav animated:YES completion:nil];
}
- (void)hideViewController:(SelectPictureViewController *)vc {
    [[LoadingView sharedInstance] hide];
    [[WebApi sharedInstance] checkNewBadges];
    [self openMenuItem:MenuHome];
    self.sideNavView.hidden = NO;
}


- (void)presentAddPredictionViewController {
    AddPredictionViewController *vc = [[AddPredictionViewController alloc] initWithActiveGroup:self.activeGroup];
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
    [self.visibleViewController pushViewController:vc animated:YES];
}


- (void)searchViewControllerDidFinish:(SearchViewController *)searchViewController {
    [self.rightSideBarButtonsView setSearchButtonHidden:NO];
}

- (void)dealloc {
    [self removeAllObservations];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)showViewController:(UINavigationController *)navigationController {
	if (self.visibleViewController)
		[self.visibleViewController.view removeFromSuperview];
	
	navigationController.view.frame = CGRectMake(self.sideNavView.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
	
	self.visibleViewController = navigationController;
	self.scrollView.detailsView = navigationController.view;
	
	[self.scrollView addSubview:navigationController.view];
	[self hideSideNav];
}

- (void)toggleSideNav {
	if (self.sideNavVisible)
		[self hideSideNav];
	else
		[self showSideNav];
}

- (void)showSideNav {
	[self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)hideSideNav {
//    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
//        [[self appDelegate] window].backgroundColor = [UIColor colorFromHex:@"77BC1F"];
//    }
	[self.scrollView setContentOffset:CGPointMake(self.sideNavView.frame.size.width, 0) animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	CGRect frame = self.sideNavView.frame;
	frame.origin.x = scrollView.contentOffset.x;
	self.sideNavView.frame = frame;

	if (scrollView.contentOffset.x == 0) {
		self.sideNavVisible = YES;
		self.scrollView.bezelWidth = self.view.frame.size.width;
		self.visibleViewController.topViewController.view.userInteractionEnabled = NO;
	}
	else if (scrollView.contentOffset.x == self.sideNavView.frame.size.width) {
		self.sideNavVisible = NO;
		self.scrollView.bezelWidth = SideNavBezelWidth;
		self.visibleViewController.topViewController.view.userInteractionEnabled = YES;
	}
}

- (CGFloat)sideNavDistanceFromClosed {
	return self.scrollView.contentOffset.x;
}

- (CGFloat)sideNavDistanceFromOpen {
	return ABS(self.sideNavView.frame.size.width - self.scrollView.contentOffset.x);
}

@end
