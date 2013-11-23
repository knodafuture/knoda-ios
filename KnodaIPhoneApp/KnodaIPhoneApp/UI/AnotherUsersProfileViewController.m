//
//  ProfileMainViewController.m
//  KnodaIPhoneApp
//
//  Created by Vyacheslav Nechiporenko on 8/21/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "AnotherUsersProfileViewController.h"
#import "NavigationViewController.h"
#import "AnotherUserProfileWebRequest.h"
#import "AnotherUserPredictionsWebRequest.h"
#import "PredictionCell.h"
#import "BindableView.h"
#import "PredictionDetailsViewController.h"
#import "PredictionAgreeWebRequest.h"
#import "PredictionDisagreeWebRequest.h"
#import "ChellangeByPredictionWebRequest.h"
#import "LoadingView.h"
#import "PredictionUpdateWebRequest.h"
#import "LoadingCell.h"
#import "UserProfileHeaderView.h"

static NSString* const kPredictionDetailsSegue = @"PredictionDetailsSegue";

@interface AnotherUsersProfileViewController () <PredictionCellDelegate, PredictionDetailsDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *predictionsTableView;

@property (nonatomic, strong) NSMutableArray * predictions;

@property (nonatomic, strong) NSTimer* cellUpdateTimer;

@property (strong, nonatomic) UserProfileHeaderView *headerView;
@property (strong, nonatomic) UITableViewCell *headerCell;

@end

@implementation AnotherUsersProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[LoadingView sharedInstance] show];
    [self setUpUsersInfo];

    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backButtonWithTarget:self action:@selector(backPressed:)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem addPredictionBarButtonItem];
    
    self.headerView = [[UserProfileHeaderView alloc] init];
    
    self.headerCell = [[UITableViewCell alloc] init];
    
    self.headerCell.frame = self.headerView.bounds;
    
    [self.headerCell addSubview:self.headerView];
    
    
}
- (void)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void) viewDidAppear: (BOOL) animated
{
    [super viewDidAppear: animated];
    [Flurry logEvent: @"Another_User_Profile_Screen" withParameters: nil timed: YES];
}


- (void) viewDidDisappear: (BOOL) animated
{
    [super viewDidDisappear: animated];
    [Flurry endTimedEvent: @"Another_User_Profile_Screen" withParameters: nil];
}


- (void) updateVisibleCells
{
    NSArray* visibleCells = [self.predictionsTableView visibleCells];
    
    for (PredictionCell* cell in visibleCells)
    {
        [cell updateDates];
    }
}

- (void) setUpUsersInfo {
    if (!self.userId) {
        return;
    }
    
    __weak AnotherUsersProfileViewController *weakSelf = self;
    
    AnotherUserProfileWebRequest *profileWebRequest = [[AnotherUserProfileWebRequest alloc]initWithUserId:self.userId];
    
    [self executeRequest:profileWebRequest withBlock:^{
        
        AnotherUsersProfileViewController *strongSelf = weakSelf;
        if(!strongSelf) {
            [[LoadingView sharedInstance] hide];
            return;
        }
        
        if (!profileWebRequest.isSucceeded) {
            [[LoadingView sharedInstance] hide];
            return;
        }
        
        [strongSelf setUpUserProfileInformationWithUser:profileWebRequest.user];
        
        AnotherUserPredictionsWebRequest *predictionWebRequest = [[AnotherUserPredictionsWebRequest alloc]initWithUserId:strongSelf.userId];
        
        [strongSelf executeRequest:predictionWebRequest withBlock:^{
            
            if (!predictionWebRequest.isSucceeded) {
                [[LoadingView sharedInstance] hide];
                return;
            }
            
            strongSelf.predictions = [NSMutableArray arrayWithArray: predictionWebRequest.predictions];
            [strongSelf.predictionsTableView reloadData];
            [[LoadingView sharedInstance] hide];
        }];
    }];
}

- (void) setUpUserProfileInformationWithUser : (User *) user {
    [self.headerView populateWithUser:user];
    self.title = user.name.uppercaseString;
}


- (IBAction)backButtonPress:(id)sender {
    [self cancelAllRequests];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Segues

- (void) prepareForSegue: (UIStoryboardSegue*) segue sender: (id) sender
{
    if([segue.identifier isEqualToString:kPredictionDetailsSegue]) {
        PredictionDetailsViewController *vc = (PredictionDetailsViewController *)segue.destinationViewController;
        vc.prediction = sender;
        vc.shouldNotOpenProfile = YES;
        vc.delegate = self;
    }
}

#pragma mark - TableView datasource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0)
        return self.headerCell.frame.size.height;
    
    if (indexPath.row != self.predictions.count)
        return [PredictionCell heightForPrediction:[self.predictions objectAtIndex:indexPath.row]];
    else
        return loadingCellHeight;
}
- (NSInteger) tableView: (UITableView*) tableView numberOfRowsInSection: (NSInteger) section {
    
    if (section == 0)
        return 1;
    
    return (self.predictions.count != 0) ? ((self.predictions.count >= [AnotherUserPredictionsWebRequest limitByPage]) ? self.predictions.count + 1 : self.predictions.count) : 1;
}

- (UITableViewCell*) tableView: (UITableView*) tableView cellForRowAtIndexPath: (NSIndexPath*) indexPath
{
    
    if (indexPath.section == 0) {
        return self.headerCell;
    }
    
    UITableViewCell* tableCell;
    
    if (indexPath.row != self.predictions.count)
    {
        Prediction* prediction = [self.predictions objectAtIndex: indexPath.row];
        
        PredictionCell* cell = [PredictionCell predictionCellForTableView:tableView];
        
        [cell fillWithPrediction: prediction];
        cell.delegate = self;

        
        tableCell = cell;
    }
    else
        return [LoadingCell loadingCellForTableView:tableView];
    
    return tableCell;
}

#pragma mark - TableView delegate

- (void) tableView: (UITableView*) tableView willDisplayCell: (UITableViewCell*) cell forRowAtIndexPath: (NSIndexPath*) indexPath
{
    if ((self.predictions.count >= [AnotherUserPredictionsWebRequest limitByPage]) && indexPath.row == self.predictions.count)
    {
        __weak AnotherUsersProfileViewController *weakSelf = self;
        
        AnotherUserPredictionsWebRequest* predictionsRequest = [[AnotherUserPredictionsWebRequest alloc] initWithLastId:((Prediction*)[self.predictions lastObject]).ID andUserID:self.userId];

        [self executeRequest:predictionsRequest withBlock:^{
            
            AnotherUsersProfileViewController *strongSelf = weakSelf;
            if(!strongSelf) return;
            
            if (predictionsRequest.isSucceeded && predictionsRequest.predictions.count != 0)
            {
                [strongSelf.predictions addObjectsFromArray: [NSMutableArray arrayWithArray: predictionsRequest.predictions] ];
                [strongSelf.predictionsTableView reloadData];
            }
            else
            {
                [strongSelf.predictionsTableView scrollToRowAtIndexPath: [NSIndexPath indexPathForRow: indexPath.row - 1 inSection: 0] atScrollPosition: UITableViewScrollPositionBottom animated: YES];
            }
        }];
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.predictions.count != 0)
    {
        [tableView deselectRowAtIndexPath: indexPath animated: YES];
        Prediction* prediction = [self.predictions objectAtIndex: indexPath.row];
        [self performSegueWithIdentifier:kPredictionDetailsSegue sender:prediction];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    UITableViewCell *stickyCell = self.headerCell;
    CGRect frame = stickyCell.frame;
    frame.origin.y = scrollView.contentOffset.y * 0.5;
    
    stickyCell.frame = frame;
    
    [stickyCell.superview sendSubviewToBack:stickyCell];
    
    
}
#pragma mark - PredictionCellDelegate


- (void) predictionAgreed: (Prediction*) prediction inCell: (PredictionCell*) cell
{
    __weak AnotherUsersProfileViewController *weakSelf = self;
    
    PredictionAgreeWebRequest* request = [[PredictionAgreeWebRequest alloc] initWithPredictionID: prediction.ID];
    [request executeWithCompletionBlock: ^
     {
         if(!weakSelf) {
             return;
         }
         
         if (request.errorCode == 0)
         {
             ChellangeByPredictionWebRequest* chellangeRequest = [[ChellangeByPredictionWebRequest alloc] initWithPredictionID: prediction.ID];
             [chellangeRequest executeWithCompletionBlock: ^
              {
                  if (chellangeRequest.errorCode == 0)
                  {
                      prediction.chellange = chellangeRequest.chellange;
                  }
              }];
         }
         else
         {
             UIAlertView* alert = [[UIAlertView alloc] initWithTitle: @"" message: request.localizedErrorDescription delegate: nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles: nil];
             [alert show];
             
             [cell resetAgreedDisagreed];
         }
     }];
}

- (void) predictionDisagreed: (Prediction*) prediction inCell: (PredictionCell*) cell
{
    __weak AnotherUsersProfileViewController *weakSelf = self;
    
    PredictionDisagreeWebRequest* request = [[PredictionDisagreeWebRequest alloc] initWithPredictionID: prediction.ID];
    [request executeWithCompletionBlock: ^
     {
         if(!weakSelf) {
             return;
         }
         
         if (request.errorCode == 0)
         {
             ChellangeByPredictionWebRequest* chellangeRequest = [[ChellangeByPredictionWebRequest alloc] initWithPredictionID: prediction.ID];
             [chellangeRequest executeWithCompletionBlock: ^
              {
                  if (chellangeRequest.errorCode == 0)
                  {
                      prediction.chellange = chellangeRequest.chellange;
                  }
              }];
         }
         else
         {
             UIAlertView* alert = [[UIAlertView alloc] initWithTitle: @"" message: request.localizedErrorDescription delegate: nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles: nil];
             [alert show];
             
             [cell resetAgreedDisagreed];
         }
     }];
}

#pragma mark PredictionDetailsDelegate

- (void)updatePrediction:(Prediction *)prediction {
    __weak AnotherUsersProfileViewController *weakSelf = self;
    PredictionUpdateWebRequest *updateRequest = [[PredictionUpdateWebRequest alloc] initWithPredictionId:prediction.ID];
    [self executeRequest:updateRequest withBlock:^{
        AnotherUsersProfileViewController *strongSelf = weakSelf;
        if(!strongSelf) return;
        
        if(updateRequest.isSucceeded) {
            [prediction updateWithObject:updateRequest.prediction];
            NSUInteger idx = [strongSelf.predictions indexOfObject:prediction];
            if(idx != NSNotFound) {
                [strongSelf.predictionsTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }
    }];
}

@end
