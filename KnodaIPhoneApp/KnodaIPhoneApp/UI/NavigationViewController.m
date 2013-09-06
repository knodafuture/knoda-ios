//
//  NavigationViewController.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/24/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "NavigationViewController.h"
#import "AppDelegate.h"
#import "ProfileCell.h"
#import "NavigationSegue.h"
#import "ProfileWebRequest.h"
#import "SelectPictureViewController.h"
#import "AlertNavigationCell.h"
#import "AllAlertsWebRequest.h"

static NSString* const kHomeSegue = @"HomeSegue";
static NSString* const kSelectPictureSegue = @"SelectPictureSegue";

static const NSInteger kAlertCellIndex = 2;

static NSString* const MENU_SEGUES[MenuItemsCount] = {
    @"HomeSegue",
    @"HistorySegue",
    @"AlertsSegue",
    @"BadgesSegue",
    @"ProfileSegue"
};

@interface NavigationViewController () <SelectPictureDelegate>

@property (weak, nonatomic) IBOutlet UILabel *pointsLabel;
@property (weak, nonatomic) IBOutlet UILabel *wonLostLabel;
@property (weak, nonatomic) IBOutlet UILabel *wonPercantageLabel;
@property (weak, nonatomic) IBOutlet UILabel *steakLabel;

@property (nonatomic, strong) IBOutlet UIView* masterView;
@property (nonatomic, strong) IBOutlet UIView* detailsView;
@property (nonatomic, strong) IBOutlet UIView* movingView;
@property (weak, nonatomic)   IBOutlet UITableView *menuItemsTableView;

@property (weak, nonatomic) IBOutlet UIView *gestureView;

@property (nonatomic, assign) BOOL appeared;

@property (nonatomic, assign) BOOL masterShown;

@property (nonatomic, strong) AppDelegate * appDelegate;

@end

@implementation NavigationViewController


- (void) viewDidLoad {
    [super viewDidLoad];
    
    [self reloadUserInfo];
    
    UITapGestureRecognizer * recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(toggleNavigationPanel)];
    [self.gestureView addGestureRecognizer:recognizer];
    
    [self updateAlertBadge];
    
    if(self.appDelegate.user.hasAvatar)
    {
        if (self.appDelegate.notificationReceived)
        {
            [self openMenuItem: MenuAlerts];
            self.appDelegate.notificationReceived = NO;
        }
        else
        {
            [self openMenuItem: MenuHome];
        }
    }
    else
    {
        [self performSegueWithIdentifier: kSelectPictureSegue sender: self];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(showAlerts) name: kAlertNotification object: nil];
}

- (void) viewDidUnload
{
    self.masterView = nil;
    self.detailsView = nil;
    self.movingView = nil;
    self.gestureView = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    
    [super viewDidUnload];
}

- (void) viewDidAppear: (BOOL) animated
{
    [super viewDidAppear:animated];
    
    self.appeared = YES;
    
    if (self.appDelegate.notificationReceived)
    {
        [self openMenuItem: MenuAlerts];
        self.appDelegate.notificationReceived = NO;
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self cancelAllRequests];
}


- (void) prepareForSegue: (UIStoryboardSegue*) segue sender: (id) sender
{
    if([segue isKindOfClass:[NavigationSegue class]]) {
        ((NavigationSegue*)segue).detailsView = self.detailsView;
        ((NavigationSegue*)segue).completion = ^{[self moveToDetailsAnimated: self.appeared];};
        self.detailsController = segue.destinationViewController;
    }
    else if([segue.identifier isEqualToString:kSelectPictureSegue]) {
        SelectPictureViewController *vc = (SelectPictureViewController *)segue.destinationViewController;
        vc.delegate = self;
    }
}


- (void) showAlerts
{
    [self.navigationController dismissViewControllerAnimated: YES completion: nil];
    [self openMenuItem: MenuAlerts];
}


- (void)openMenuItem:(MenuItem)menuItem {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:menuItem inSection:0];
    [self.menuItemsTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    if(!self.masterShown && self.appeared) {
        [self moveToMaster];
    }
    [self performSegueWithIdentifier:MENU_SEGUES[menuItem] sender:self];
}

- (void) moveToDetailsAnimated: (BOOL) animated
{
    if (animated)
    {
        [UIView animateWithDuration: 0.3 animations: ^
         {
             [self moveToDetails];
         }];
    }
    else
    {
        [self moveToDetails];
    }
}


- (void) moveToDetails
{
    [Flurry endTimedEvent: @"Navigation_Screen" withParameters: nil];
    
    self.masterShown = NO;
    self.gestureView.hidden = YES;
    
    CGRect newFrame = self.movingView.frame;
    newFrame.origin.x -= self.masterView.frame.size.width;
    self.movingView.frame = newFrame;
}


- (void) moveToMaster
{
    [Flurry logEvent: @"Navigation_Screen" withParameters: nil timed: YES];
    
    [self reloadUserInfo];
    
    self.masterShown = YES;
    self.gestureView.hidden = NO;
    
    [self updateAlertBadge];
    [self updateUserInfo];
    
    [UIView animateWithDuration: 0.3 animations: ^
     {
         CGRect newFrame = self.movingView.frame;
         newFrame.origin.x += self.masterView.frame.size.width;
         self.movingView.frame = newFrame;
     }];
}


- (void) toggleNavigationPanel
{
    if (self.masterShown)
    {   
        [self moveToDetailsAnimated: YES];
    }
    else
    {
        self.gestureView.hidden = NO;
        [self moveToMaster];
    }
}

- (void) animatedMoveToDetailsWithGestureRecognizer : (UITapGestureRecognizer *) recognizer {
    [self moveToDetailsAnimated:YES];
}


- (AppDelegate*) appDelegate
{
    return [UIApplication sharedApplication].delegate;
}

#pragma mark - User's info update 

- (void) reloadUserInfo {
    
    __weak NavigationViewController *weakSelf = self;
    
    ProfileWebRequest *profileWebRequest = [[ProfileWebRequest alloc]init];
    
    [self executeRequest:profileWebRequest withBlock:^{
        
        NavigationViewController *strongSelf = weakSelf;
        if(!strongSelf) return;
        
        if (profileWebRequest.isSucceeded)
        {
            [strongSelf.appDelegate.user updateWithObject:profileWebRequest.user];
        }
        [strongSelf updateUserInfo];
    }];
}

- (void) updateUserInfo {
    User * user = self.appDelegate.user;
    self.pointsLabel.text = [NSString stringWithFormat:@"%d",user.points];
    self.wonLostLabel.text = [NSString stringWithFormat:@"%d-%d",user.won,user.lost];
    self.wonPercantageLabel.text = ![user.winningPercentage isEqual: @0] ? [NSString stringWithFormat:@"%@%@",user.winningPercentage,@"%"] : @"0%";
    self.steakLabel.text = [user.streak length] > 0 ? user.streak : @"-";
    
    NSIndexPath *selectedIndexPath = [self.menuItemsTableView indexPathForSelectedRow];
    
    [self.menuItemsTableView beginUpdates];
    [self.menuItemsTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:MenuProfile inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.menuItemsTableView endUpdates];
    
    if(![self.menuItemsTableView indexPathForSelectedRow] && selectedIndexPath) {
        [self.menuItemsTableView selectRowAtIndexPath:selectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}


#pragma mark - Badge update


- (void) updateAlertBadge
{
    AllAlertsWebRequest* request = [[AllAlertsWebRequest alloc] init];
    AlertNavigationCell* cell = (AlertNavigationCell*)[self.menuItemsTableView cellForRowAtIndexPath: [NSIndexPath indexPathForRow: kAlertCellIndex inSection: 0]];
    [self executeRequest:request withBlock:^{
        if (request.isSucceeded)
        {
            [cell updateBadge: request.predictions.count];
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber: request.predictions.count];
        }
    }];
}


#pragma mark - UITableViewDataSource


- (NSInteger) tableView: (UITableView*) tableView numberOfRowsInSection: (NSInteger) section
{
    return MenuItemsCount;
}


- (UITableViewCell*) tableView: (UITableView*) tableView cellForRowAtIndexPath: (NSIndexPath*) indexPath
{
    NSString* identefier = @"";
    
    switch (indexPath.row) {
        case MenuHome:
            identefier = @"HomeCell";
            break;
        case MenuHistory:
            identefier = @"HistoryCell";
            break;
        case MenuAlerts:
            identefier = @"AlertsCell";
            break;
        case MenuBadges:
            identefier = @"BadgesCell";
            break;
        case MenuProfile:
            identefier = @"ProfileCell";
            break;
            
        default:
            break;
    }
    if (indexPath.row != MenuProfile) {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: identefier];
        return cell;
    }
    else {
        ProfileCell * cell = [tableView dequeueReusableCellWithIdentifier: identefier];
        [cell setupWithUser:self.appDelegate.user];
        return cell;
    }
}

#pragma mark SelectPictureDelegate

- (void)hideViewController:(SelectPictureViewController *)vc {
    [vc.navigationController popViewControllerAnimated:NO];
    [self performSegueWithIdentifier: kHomeSegue sender: self];
}

@end
