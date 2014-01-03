//
//  ProfileMainViewController.m
//  KnodaIPhoneApp
//
//  Created by Vyacheslav Nechiporenko on 8/21/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "AnotherUsersProfileViewController.h"
#import "NavigationViewController.h"
#import "PredictionCell.h"
#import "PredictionDetailsViewController.h"
#import "LoadingView.h"
#import "LoadingCell.h"
#import "UserProfileHeaderView.h"
#import "WebApi.h"
#import "ZoomingImageViewController.h"

@interface AnotherUsersProfileViewController ()

@property (strong, nonatomic) UserProfileHeaderView *headerView;
@property (strong, nonatomic) UITableViewCell *headerCell;
@property (assign, nonatomic) NSInteger userId;
@property (assign, nonatomic) BOOL userInfoLoaded;

@end

@implementation AnotherUsersProfileViewController

- (id)initWithUserId:(NSInteger)userId {
    self = [super initWithStyle:UITableViewStylePlain];
    self.userId = userId;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"PROFILE";
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backButtonWithTarget:self action:@selector(backPressed:)];
    
    self.headerView = [[UserProfileHeaderView alloc] init];
    
    self.headerCell = [[UITableViewCell alloc] init];
    self.headerCell.selectionStyle = UITableViewCellSelectionStyleNone;
    self.headerCell.frame = self.headerView.bounds;
    
    [self.headerCell addSubview:self.headerView];
}
- (void)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [Flurry logEvent:@"Another_User_Profile_Screen" withParameters:nil timed:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [Flurry endTimedEvent:@"Another_User_Profile_Screen" withParameters:nil];
}

- (void)loadUserInfo:(void(^)(void))completion {
    [[WebApi sharedInstance] getUser:self.userId completion:^(User *user, NSError *error) {
        if (!error) {
            self.userInfoLoaded = YES;
            [self setUpUserProfileInformationWithUser:user];
            completion();
        } else {
            [[LoadingView sharedInstance] hide];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Unable to load profile at this time" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

- (void)setUpUserProfileInformationWithUser:(User *) user {
    [self.headerView populateWithUser:user];
    self.title = user.name.uppercaseString;
}


- (IBAction)backButtonPress:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.userInfoLoaded)
        return 2;
    else
        return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0 && self.userInfoLoaded)
        return self.headerCell.frame.size.height;
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0 && self.userInfoLoaded)
        return 1;
    
    return [super tableView:tableView numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && self.userInfoLoaded)
        return self.headerCell;
    
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.pagingDatasource.objects.count)
        return;
    
    if (indexPath.section == 0) {
        ZoomingImageViewController *vc = [[ZoomingImageViewController alloc] initWithImage:self.headerView.avatarImageView.image title:self.title];
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    
    Prediction *prediction = [self.pagingDatasource.objects objectAtIndex:indexPath.row];
    
    PredictionDetailsViewController *vc = [[PredictionDetailsViewController alloc] initWithPrediction:prediction];
    vc.delegate = self;
    vc.shouldNotOpenProfile = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0)
        return;
    
    [super tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    
}

- (void)objectsAfterObject:(id)object completion:(void (^)(NSArray *, NSError *))completionHandler {
    NSInteger lastId = [(Prediction *)object predictionId];
    
    if (self.pagingDatasource.currentPage == 0) {
        [self loadUserInfo:^{
            [[WebApi sharedInstance] getPredictionsForUser:self.userId after:lastId completion:completionHandler];
        }];
    } else
        [[WebApi sharedInstance] getPredictionsForUser:self.userId after:lastId completion:completionHandler];
}

- (void)profileSelectedWithUserId:(NSInteger)userId inCell:(PredictionCell *)cell {

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    UITableViewCell *stickyCell = self.headerCell;
    CGRect frame = stickyCell.frame;
    if (scrollView.contentOffset.y < 0)
        return;
    frame.origin.y = scrollView.contentOffset.y * 0.5;
    
    stickyCell.frame = frame;
    
    [stickyCell.superview sendSubviewToBack:stickyCell];
    [stickyCell.superview sendSubviewToBack:self.refreshControl];
}
@end
