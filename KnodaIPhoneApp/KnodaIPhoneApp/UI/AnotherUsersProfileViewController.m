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
#import "AddPredictionViewController.h"
#import "PreditionCell.h"
#import "BindableView.h"
#import "PredictionDetailsViewController.h"
#import "PredictionAgreeWebRequest.h"
#import "PredictionDisagreeWebRequest.h"
#import "ChellangeByPredictionWebRequest.h"

static NSString* const kPredictionDetailsSegue = @"PredictionDetailsSegue";
static NSString* const kAddPredictionSegue     = @"AddPredictionSegue";

@interface AnotherUsersProfileViewController () <AddPredictionViewControllerDelegate, PredictionCellDelegate>

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userPointsLabel;
@property (weak, nonatomic) IBOutlet UILabel *userTotalPredictionsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userProfileImageView;
@property (weak, nonatomic) IBOutlet UITableView *predictionsTableView;
@property (weak, nonatomic) IBOutlet UIView *activityView;
@property (weak, nonatomic) IBOutlet BindableView *userAvatarView;

@property (nonatomic, strong) NSMutableArray * predictions;

@property (nonatomic, strong) NSTimer* cellUpdateTimer;

@end

@implementation AnotherUsersProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"darkBgPattern"]];
    self.navigationController.navigationBar.frame = CGRectMake(0, 0, self.view.frame.size.width, self.navigationController.navigationBar.frame.size.height);
    [self.navigationController.navigationBar setTitleVerticalPositionAdjustment:5 forBarMetrics:UIBarMetricsDefault];
    self.activityView.hidden = NO;
    [self setUpUsersInfo];
}

- (void) updateVisibleCells
{
    NSArray* visibleCells = [self.predictionsTableView visibleCells];
    
    for (PreditionCell* cell in visibleCells)
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
    [profileWebRequest executeWithCompletionBlock:^{
        
        AnotherUsersProfileViewController *strongSelf = weakSelf;
        if(!strongSelf) {
            return;
        }
        
        if (profileWebRequest.errorCode != 0) {
            strongSelf.activityView.hidden = YES;
            return;
        }
        
        [strongSelf setUpUserProfileInformationWithUser:profileWebRequest.user];
        AnotherUserPredictionsWebRequest *predictionWebRequest = [[AnotherUserPredictionsWebRequest alloc]initWithUserId:strongSelf.userId];
        [predictionWebRequest executeWithCompletionBlock:^{
            
            if (predictionWebRequest.errorCode != 0) {
                strongSelf.activityView.hidden = YES;
                return;
            }
            
            strongSelf.predictions = [NSMutableArray arrayWithArray: predictionWebRequest.predictions];
            [strongSelf.predictionsTableView reloadData];
            strongSelf.activityView.hidden = YES;
        }];
    }];
}

- (void) setUpUserProfileInformationWithUser : (User *) user {
    [self.userAvatarView bindToURL:user.smallImage];
    self.userNameLabel.text = user.name;
    self.userPointsLabel.text = [NSString stringWithFormat:@"%d @%@",user.points, NSLocalizedString(@"points", @"")];
    self.userTotalPredictionsLabel.text = [NSString stringWithFormat:@"%d %@",user.totalPredictions, NSLocalizedString(@"total predictions", @"")];
}


- (IBAction)backButtonPress:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Segues

- (void) prepareForSegue: (UIStoryboardSegue*) segue sender: (id) sender
{
    if ([segue.identifier isEqualToString:kAddPredictionSegue]) {
        ((AddPredictionViewController*)segue.destinationViewController).delegate = self;
    }
    else if([segue.identifier isEqualToString:kPredictionDetailsSegue]) {
        PredictionDetailsViewController *vc = (PredictionDetailsViewController *)segue.destinationViewController;
        vc.prediction = sender;
        vc.addPredictionDelegate = self;
    }
}

#pragma mark - AddPredictionViewControllerDelegate

- (void) predictionWasMadeInController:(AddPredictionViewController *)vc
{
    [vc dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TableView datasource

- (NSInteger) numberOfSectionsInTableView: (UITableView*) tableView
{
    return 1;
}

- (NSInteger) tableView: (UITableView*) tableView numberOfRowsInSection: (NSInteger) section
{
    return (self.predictions.count != 0) ? ((self.predictions.count >= [AnotherUserPredictionsWebRequest limitByPage]) ? self.predictions.count + 1 : self.predictions.count) : 1;
}

- (UITableViewCell*) tableView: (UITableView*) tableView cellForRowAtIndexPath: (NSIndexPath*) indexPath
{
    UITableViewCell* tableCell;
    
    if (indexPath.row != self.predictions.count)
    {
        Prediction* prediction = [self.predictions objectAtIndex: indexPath.row];
        
        PreditionCell* cell = [tableView dequeueReusableCellWithIdentifier:[PreditionCell reuseIdentifier]];
        
        [cell fillWithPrediction: prediction];
        cell.delegate = self;
        
        UIPanGestureRecognizer* recognizer = [[UIPanGestureRecognizer alloc] init];
        [cell addPanGestureRecognizer: recognizer];
        
        tableCell = cell;
    }
    else
    {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: @"LoadingCell"];
        tableCell = cell;
    }
    
    return tableCell;
}

#pragma mark - TableView delegate

- (void) tableView: (UITableView*) tableView willDisplayCell: (UITableViewCell*) cell forRowAtIndexPath: (NSIndexPath*) indexPath
{
    if ((self.predictions.count >= [AnotherUserPredictionsWebRequest limitByPage]) && indexPath.row == self.predictions.count)
    {
        AnotherUserPredictionsWebRequest* predictionsRequest = [[AnotherUserPredictionsWebRequest alloc] initWithLastId:((Prediction*)[self.predictions lastObject]).ID andUserID:self.userId];

        [predictionsRequest executeWithCompletionBlock: ^
         {
             if (predictionsRequest.errorCode == 0 && predictionsRequest.predictions.count != 0)
             {
                 [self.predictions addObjectsFromArray: [NSMutableArray arrayWithArray: predictionsRequest.predictions] ];
                 [self.predictionsTableView reloadData];
             }
             else
             {
                 [self.predictionsTableView scrollToRowAtIndexPath: [NSIndexPath indexPathForRow: indexPath.row - 1 inSection: 0] atScrollPosition: UITableViewScrollPositionBottom animated: YES];
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

#pragma mark - PredictionCellDelegate


- (void) predictionAgreed: (Prediction*) prediction inCell: (PreditionCell*) cell
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

- (void) predictionDisagreed: (Prediction*) prediction inCell: (PreditionCell*) cell
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

@end
