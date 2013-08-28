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

#import "BadgesWebRequest.h"

static NSString* const kHomeSegue = @"HomeSegue";
static NSString* const kSelectPictureSegue = @"SelectPictureSegue";

static NSString* const MENU_SEGUES[MenuItemsSize] = {
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

@property (nonatomic, assign) BOOL appeared;

@property (nonatomic, strong) NSTimer* userUpdateTimer;

@property (nonatomic, assign) BOOL masterShown;

@property (nonatomic, strong) AppDelegate * appDelegate;

@end

@implementation NavigationViewController


- (void) viewDidLoad {
    [super viewDidLoad];
    
    if(self.appDelegate.user.hasAvatar) {
        [self performSegueWithIdentifier: kHomeSegue sender: self];
    }
    else {
        [self performSegueWithIdentifier: kSelectPictureSegue sender: self];
    }
}

- (void) viewDidUnload
{
    self.masterView = nil;
    self.detailsView = nil;
    self.movingView = nil;
    self.userUpdateTimer = nil;
    
    [super viewDidUnload];
}

- (void) viewDidAppear: (BOOL) animated
{
    [super viewDidAppear:animated];
    self.appeared = YES;
    self.userUpdateTimer = [NSTimer scheduledTimerWithTimeInterval: 1800.0 target: self selector: @selector(reloadUserInfo) userInfo: nil repeats: YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.userUpdateTimer invalidate];
    self.userUpdateTimer = nil;
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

- (void)openMenuItem:(MenuItem)menuItem {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:menuItem inSection:0];
    [self.menuItemsTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    if(!self.masterShown) {
        [self moveToMaster];
    }
    [self performSegueWithIdentifier:MENU_SEGUES[menuItem] sender:nil];
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
    self.masterShown = NO;
    
    CGRect newFrame = self.movingView.frame;
    newFrame.origin.x -= self.masterView.frame.size.width;
    self.movingView.frame = newFrame;
}


- (void) moveToMaster
{
    self.masterShown = YES;
    
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
        [self moveToMaster];
    }
}


- (AppDelegate*) appDelegate
{
    return [UIApplication sharedApplication].delegate;
}

#pragma mark - User's info update 

- (void) reloadUserInfo {
    ProfileWebRequest *profileWebRequest = [[ProfileWebRequest alloc]init];
    [profileWebRequest executeWithCompletionBlock:^{
        if (profileWebRequest.isSucceeded)
        {
            [self.appDelegate.user updateWithObject:profileWebRequest.user];
        }
        [self updateUserInfo];
    }];
}

- (void) updateUserInfo {
    User * user = self.appDelegate.user;
    self.pointsLabel.text = [NSString stringWithFormat:@"%d",user.points];
    self.wonLostLabel.text = [NSString stringWithFormat:@"%d-%d",user.won,user.lost];
    self.wonPercantageLabel.text = ![user.winningPercentage isEqual: @0] ? [NSString stringWithFormat:@"%@%@",user.winningPercentage,@"%"] : @"0%";
    self.steakLabel.text = [user.streak length] > 0 ? user.streak : @"-";
    
    [self.menuItemsTableView beginUpdates];    
    [self.menuItemsTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:4 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.menuItemsTableView endUpdates];
}

#pragma mark - UITableViewDataSource


- (NSInteger) numberOfSectionsInTableView: (UITableView*) tableView
{
    return 1;
}


- (NSInteger) tableView: (UITableView*) tableView numberOfRowsInSection: (NSInteger) section
{
    return 5;
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
    
    if(self.appDelegate.user.justSignedUp) {
        [BadgesWebRequest checkNewBadges];
    }
}

@end
