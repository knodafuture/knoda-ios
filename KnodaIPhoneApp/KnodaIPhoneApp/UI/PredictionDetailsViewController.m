//
//  PredictionDetailsViewController.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 8/6/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "PredictionDetailsViewController.h"
#import "AnotherUsersProfileViewController.h"
#import "Prediction.h"
#import "Chellange.h"
#import "ProfileViewController.h"
#import "LoadingCell.h"
#import "User.h"
#import "PredictorCell.h"
#import "PredictionUsersWebRequest.h"
#import "BSWebRequest.h"
#import "OutcomeWebRequest.h"
#import "ChellangeByPredictionWebRequest.h"
#import "PredictionAgreeWebRequest.h"
#import "PredictionDisagreeWebRequest.h"
#import "PredictionUpdateWebRequest.h"
#import "CategoryPredictionsViewController.h"
#import "AppDelegate.h"

#import "BigDaddyPredictionCell.h"
#import "PredictionDetailsSectionHeader.h"

static NSString* const kCategorySegue      = @"CategoryPredictionsSegue";
static NSString* const kUserProfileSegue   = @"UserProfileSegue";
static NSString* const kMyProfileSegue     = @"MyProfileSegue";

static const int kBSAlertTag = 1001;

static const float parallaxRatio = 0.5;

@interface PredictionDetailsViewController () <UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate, PredictionCellDelegate> {
    BOOL _loadingUsers;
    BOOL _updatingStatus;
}

@property (nonatomic, strong) AppDelegate * appDelegate;

@property (nonatomic) NSArray *agreedUsers;
@property (nonatomic) NSArray *disagreedUsers;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) BigDaddyPredictionCell *predictionCell;
@property (strong, nonatomic) PredictionDetailsSectionHeader *sectionHeader;

@end

@implementation PredictionDetailsViewController

#pragma mark View lifecycle

- (void)dealloc {
    [[(AppDelegate *)[[UIApplication sharedApplication] delegate] user] removeObserver:self forKeyPath:@"smallImage"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _loadingUsers = YES;
    [self updateUsers];
    
    [[(AppDelegate *)[[UIApplication sharedApplication] delegate] user] addObserver:self forKeyPath:@"smallImage" options:NSKeyValueObservingOptionNew context:nil];
    self.title = @"DETAILS";
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backButtonWithTarget:self action:@selector(backPressed:)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem addPredictionBarButtonItem];
    
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"basicCell"];
    
    self.predictionCell = [BigDaddyPredictionCell predictionCellWithOwner:self];
    self.sectionHeader = [PredictionDetailsSectionHeader sectionHeaderWithOwner:self];
    
    [self.predictionCell configureWithPrediction:self.prediction];
    [self.tableView reloadData];
}


- (void) viewDidAppear: (BOOL) animated
{
    [super viewDidAppear: animated];
    [Flurry logEvent: @"Prediction_Details_Screen" timed: YES];
}

- (void) viewDidDisappear: (BOOL) animated
{
    [super viewDidDisappear: animated];
    [Flurry endTimedEvent: @"Prediction_Details_Screen" withParameters: nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([object isKindOfClass:[User class]] && [keyPath isEqualToString:@"smallImage"]) {
        self.prediction.smallAvatar = [(User *)object smallImage];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
- (void)reloadPredictorsTable {
    //[self.predictorsTable reloadData];
    
    //self.agreedNumberLabel.text = [NSString stringWithFormat:@"%d AGREED", self.prediction.agreeCount];
    //self.disagreedNumberLabel.text = [NSString stringWithFormat:@"%d DISAGREED", self.prediction.disagreeCount];
    
}


#pragma mark Actions
- (IBAction)share:(id)sender {
    UIActivityViewController *vc = [[UIActivityViewController alloc] initWithActivityItems:@[self.prediction.body] applicationActivities:nil];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)backPressed:(UIButton *)sender {
    if(self.delegate && [self getWebRequests].count) { //update prediction in case if some changes weren't handled
        [self.delegate updatePrediction:self.prediction];
    }
    [self cancelAllRequests];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)bsButtonTapped:(UIButton *)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Don't be lame. Tell the truth. It's more fun this way. Is this really the wrong outcome?", @"")
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                              otherButtonTitles:NSLocalizedString(@"Yes", @""), nil];
    alertView.tag = kBSAlertTag;
    [alertView show];
}

- (IBAction)agreeButtonTapped:(UIButton *)sender {
    [Flurry logEvent: @"Agree_Button_Tapped"];
    [self sendAgree:YES];
}

- (IBAction)disagreeButtonTapped:(UIButton *)sender {
    [Flurry logEvent: @"Disagree_Button_Tapped"];
    [self sendAgree:NO];
}

- (IBAction)yesButtonTapped:(UIButton *)sender {
    [self sendOutcome:YES];
}

- (IBAction)noButtonTapped:(UIButton *)sender {
    [self sendOutcome:NO];
}

- (IBAction)categoryButtonTapped:(UIButton *)sender {
    if(self.shouldNotOpenCategory) {
        [self backPressed:nil];
    }
    else {
        [self performSegueWithIdentifier:kCategorySegue sender:nil];
    }
}

#pragma mark Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:kCategorySegue]) {
        CategoryPredictionsViewController *vc = (CategoryPredictionsViewController *)segue.destinationViewController;
        vc.category             = self.prediction.category;
        vc.shouldNotOpenProfile = self.shouldNotOpenProfile;
    }
    else if ([segue.identifier isEqualToString:kUserProfileSegue]) {
        ((AnotherUsersProfileViewController*)segue.destinationViewController).userId = self.prediction.userId;
    }
    else if([segue.identifier isEqualToString:kMyProfileSegue]) {
        ProfileViewController *vc    = (ProfileViewController *)segue.destinationViewController;
        vc.leftButtonItemReturnsBack = YES;
    }
}

#pragma mark Private

- (void)updatePredictionUsers:(NSArray *)users agreed:(BOOL)agreed {
    if(agreed) {
        self.agreedUsers = [users arrayByAddingObject:self.prediction.userName];
    }
    else {
        self.disagreedUsers = users;
    }
    
    if(self.agreedUsers && self.disagreedUsers) {
        _loadingUsers = NO;
        
        //update prediction counters in case they're out of date
        self.prediction.agreeCount    = self.agreedUsers.count;
        self.prediction.disagreeCount = self.disagreedUsers.count;
        
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0)
        return self.predictionCell.frame.size.height;
    else
        return 30;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1)
        return predictionDetailsSectionHeaderHeight;
    else
        return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 1)
        return self.sectionHeader;
    else
        return nil;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return 1;
    else {
        if (_loadingUsers)
            return 21;
        else
            return MAX(self.agreedUsers.count, self.disagreedUsers.count) + 20;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        //[self.predictionCell update];
        return self.predictionCell;
    }
    
    if (_loadingUsers && indexPath.row == 0)
        return [tableView dequeueReusableCellWithIdentifier:@"LoadingCell" forIndexPath:indexPath];
    
    if (indexPath.row < MAX(self.agreedUsers.count, self.disagreedUsers.count) - 1) {
        PredictorCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PredictorCell" forIndexPath:indexPath];
        
        int idx = indexPath.row;
        cell.agreedUserName.text    = self.agreedUsers.count > idx ? self.agreedUsers[idx] : @"";
        cell.disagreedUserName.text = self.disagreedUsers.count > idx ? self.disagreedUsers[idx] : @"";
    
        return cell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"basicCell"];
    cell.textLabel.text = @"just here to test scrolling";
    return cell;
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    UITableViewCell *stickyCell = self.predictionCell;
    CGRect frame = stickyCell.frame;
    frame.origin.y = scrollView.contentOffset.y * parallaxRatio;
    
    stickyCell.frame = frame;
    [self.tableView sendSubviewToBack:stickyCell];
    

}
#pragma mark Requests

- (void)showErrorFromRequest:(BaseWebRequest *)request {
    [[[UIAlertView alloc] initWithTitle:@""
                                message:request.localizedErrorDescription
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"OK", @"")
                      otherButtonTitles:nil] show];
}

- (void)updateUsers {
    if(self.prediction.agreeCount || self.prediction.disagreeCount) {
        
        __weak PredictionDetailsViewController *weakSelf = self;
        
        PredictionUsersWebRequest *requestAgreed = [[PredictionUsersWebRequest alloc] initWithPredictionId:self.prediction.ID forAgreedUsers:YES];
        [self executeRequest:requestAgreed withBlock:^{
            
            PredictionDetailsViewController *strongSelf = weakSelf;
            if(!strongSelf) return;
            [strongSelf updatePredictionUsers:requestAgreed.users agreed:YES];
        }];
        
        PredictionUsersWebRequest *requestDisagreed = [[PredictionUsersWebRequest alloc] initWithPredictionId:self.prediction.ID forAgreedUsers:NO];
        [self executeRequest:requestDisagreed withBlock:^{
            
            PredictionDetailsViewController *strongSelf = weakSelf;
            if(!strongSelf) return;
            [strongSelf updatePredictionUsers:requestDisagreed.users agreed:NO];
        }];
    }
}

- (void)sendAgree:(BOOL)agree {
    
    _updatingStatus = YES;
    
    BaseWebRequest *request;
    
    if(agree) {
        request = [[PredictionAgreeWebRequest alloc] initWithPredictionID:self.prediction.ID];
    }
    else {
        request = [[PredictionDisagreeWebRequest alloc] initWithPredictionID:self.prediction.ID];
    }
    
    __weak PredictionDetailsViewController *weakSelf = self;
    
    [self executeRequest:request withBlock:^{
        PredictionDetailsViewController *strongSelf = weakSelf;
        if(!strongSelf) return;
        
        if(request.isSucceeded) {
            ChellangeByPredictionWebRequest *challengeRequest = [[ChellangeByPredictionWebRequest alloc] initWithPredictionID:strongSelf.prediction.ID];
            [strongSelf executeRequest:challengeRequest withBlock:^{
                
                strongSelf->_updatingStatus = NO;
                strongSelf.prediction.chellange = challengeRequest.chellange;
                
                if(challengeRequest.isSucceeded) {
                    [strongSelf updateUsers];
                }
                else {
                    [strongSelf showErrorFromRequest:request];
                }
                [self.tableView reloadData];
            }];
        }
        else {
            [strongSelf showErrorFromRequest:request];
            strongSelf->_updatingStatus = NO;
        }
        [self.tableView reloadData];
    }];
    
    [self.tableView reloadData];
}

- (void)sendOutcome:(BOOL)realise {
    
    _updatingStatus = YES;
    
    OutcomeWebRequest *outcomeRequest = [[OutcomeWebRequest alloc] initWithPredictionId:self.prediction.ID realise:realise];
    
    __weak PredictionDetailsViewController *weakSelf = self;
    
    [self executeRequest:outcomeRequest withBlock:^{        
        PredictionDetailsViewController *strongSelf = weakSelf;
        if(!strongSelf) return;
        
        if(outcomeRequest.isSucceeded) {            
            PredictionUpdateWebRequest *updateRequest = [[PredictionUpdateWebRequest alloc] initWithPredictionId:strongSelf.prediction.ID];
            [strongSelf executeRequest:updateRequest withBlock:^{
                
                strongSelf->_updatingStatus = NO;
                
                if(updateRequest.isSucceeded) {
                    [strongSelf.prediction updateWithObject:updateRequest.prediction];
                }
                else {
                    [strongSelf showErrorFromRequest:outcomeRequest];
                }
                [self.tableView reloadData];
            }];
        }
        else {
            strongSelf->_updatingStatus = NO;
            
            [self.tableView reloadData];
            [strongSelf showErrorFromRequest:outcomeRequest];
        }
    }];

    [self.tableView reloadData];
}

- (void)sendBS {
    
    _updatingStatus = YES;
    
    __weak PredictionDetailsViewController *weakSelf = self;

    BSWebRequest *bsRequest = [[BSWebRequest alloc] initWithPredictionId:self.prediction.ID];
    [self executeRequest:bsRequest withBlock:^{
        PredictionDetailsViewController *strongSelf = weakSelf;
        if(!strongSelf) return;
        
        if(bsRequest.isSucceeded) {
            PredictionUpdateWebRequest *updateRequest = [[PredictionUpdateWebRequest alloc] initWithPredictionId:strongSelf.prediction.ID];
            [strongSelf executeRequest:updateRequest withBlock:^{
                
                strongSelf->_updatingStatus = NO;
                
                if(updateRequest.isSucceeded) {
                    [strongSelf.prediction updateWithObject:updateRequest.prediction];
                }
                else {
                    [strongSelf showErrorFromRequest:updateRequest];
                }
                [self.tableView reloadData];
            }];
        }
        else {
            strongSelf->_updatingStatus = NO;
            [strongSelf showErrorFromRequest:bsRequest];
            [self.tableView reloadData];
        }
    }];

    [self.tableView reloadData];
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(alertView.tag == kBSAlertTag && alertView.cancelButtonIndex != buttonIndex)
    {
        [Flurry logEvent: @"BS_Button_Tapped"];
        [self sendBS];
    }
}
#pragma mark - Prediction Cell delegate

- (void)profileImageTapped:(id)sender {
    if (self.appDelegate.user.userId == self.prediction.userId)
        [self performSegueWithIdentifier:kMyProfileSegue sender:self];
    else
        [self performSegueWithIdentifier:kUserProfileSegue sender:[NSNumber numberWithInt:self.prediction.userId]];
}
#pragma mark - AppDelegate

- (AppDelegate*) appDelegate
{
    return [UIApplication sharedApplication].delegate;
}

@end