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

#import "SelectPictureViewController.h"

static NSString* const kHomeSegue = @"HomeSegue";
static NSString* const kSelectPictureSegue = @"SelectPictureSegue";
static NSString* const kAppUser = @"";

@interface NavigationViewController () <SelectPictureDelegate>

@property (weak, nonatomic) IBOutlet UILabel *pointsLabel;
@property (weak, nonatomic) IBOutlet UILabel *wonLostLabel;
@property (weak, nonatomic) IBOutlet UILabel *wonPercantageLabel;
@property (weak, nonatomic) IBOutlet UILabel *steakLabel;

@property (nonatomic, strong) IBOutlet UIView* masterView;
@property (nonatomic, strong) IBOutlet UIView* detailsView;
@property (nonatomic, strong) IBOutlet UIView* movingView;
@property (weak, nonatomic) IBOutlet UITableView *menuItemsTableView;
@property (nonatomic, assign) BOOL appeared;

@property (nonatomic, assign) BOOL masterShown;

@property (nonatomic, strong) AppDelegate * appDelegate;

@end

@implementation NavigationViewController


- (void) viewDidLoad {
    [super viewDidLoad];

    if([[(AppDelegate *)[[UIApplication sharedApplication] delegate] user] hasAvatar]) {
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
    
    [super viewDidUnload];
}


- (void) viewDidAppear: (BOOL) animated
{
    self.appeared = YES;
}


- (void) prepareForSegue: (UIStoryboardSegue*) segue sender: (id) sender
{
    if([segue isKindOfClass:[NavigationSegue class]]) {
        ((NavigationSegue*)segue).detailsView = self.detailsView;
        ((NavigationSegue*)segue).completion = ^{[self moveToDetailsAnimated: self.appeared];};
    }
    else if([segue.identifier isEqualToString:kSelectPictureSegue]) {
        SelectPictureViewController *vc = (SelectPictureViewController *)segue.destinationViewController;
        vc.delegate = self;
    }
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
        case 0:
            identefier = @"HomeCell";
            break;
        case 1:
            identefier = @"HistoryCell";
            break;
        case 2:
            identefier = @"AlertsCell";
            break;
        case 3:
            identefier = @"BadgesCell";
            break;
        case 4:
            identefier = @"ProfileCell";
            break;
            
        default:
            break;
    }
    if (indexPath.row != 4) {
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
