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
    self.activityView.hidden = NO;
    [self setUpUsersInfo];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.cellUpdateTimer = [NSTimer scheduledTimerWithTimeInterval: 60.0 target: self selector: @selector(setUpUsersInfo) userInfo: nil repeats: YES];
}

- (void) viewWillDisappear: (BOOL) animated {
    self.cellUpdateTimer = nil;    
    [super viewWillDisappear: animated];
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
    AnotherUserProfileWebRequest *profileWebRequest = [[AnotherUserProfileWebRequest alloc]initWithUserId:self.userId];
    [profileWebRequest executeWithCompletionBlock:^{
        if (profileWebRequest.errorCode != 0) {
            self.activityView.hidden = YES;
            return;
        }
        
        [self setUpUserProfileInformationWithUser:profileWebRequest.user];
        AnotherUserPredictionsWebRequest *predictionWebRequest = [[AnotherUserPredictionsWebRequest alloc]initWithUserId:self.userId];
        [predictionWebRequest executeWithCompletionBlock:^{
            
            if (predictionWebRequest.errorCode != 0) {
                self.activityView.hidden = YES;
                return;
            }
            
            self.predictions = [NSMutableArray arrayWithArray: predictionWebRequest.predictions];
            [self.predictionsTableView reloadData];
            self.activityView.hidden = YES;
        }];
        }];
}

- (void) setUpUserProfileInformationWithUser : (User *) user {
    [self.userAvatarView bindToURL:user.smallImage];
    self.userNameLabel.text = user.name;
    self.userPointsLabel.text = [NSString stringWithFormat:@"%d points",user.points];
    self.userTotalPredictionsLabel.text = [NSString stringWithFormat:@"%d total predictions",user.totalPredictions];
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
    return [self.predictions count];
}

- (UITableViewCell*) tableView: (UITableView*) tableView cellForRowAtIndexPath: (NSIndexPath*) indexPath
{
    Prediction* prediction = [self.predictions objectAtIndex: indexPath.row];
    
    PreditionCell* cell = [tableView dequeueReusableCellWithIdentifier:[PreditionCell reuseIdentifier]];
    
    [cell fillWithPrediction: prediction];
    cell.delegate = self;
    
    UIPanGestureRecognizer* recognizer = [[UIPanGestureRecognizer alloc] init];
    [cell addPanGestureRecognizer: recognizer];
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Prediction* prediction = [self.predictions objectAtIndex: indexPath.row];
    [self performSegueWithIdentifier:kPredictionDetailsSegue sender:prediction];
}

#pragma mark - PredictionCellDelegate


- (void) predictionAgreed: (Prediction*) prediction inCell: (PreditionCell*) cell
{
    PredictionAgreeWebRequest* request = [[PredictionAgreeWebRequest alloc] initWithPredictionID: prediction.ID];
    [request executeWithCompletionBlock: ^
     {
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
             UIAlertView* alert = [[UIAlertView alloc] initWithTitle: @"" message: request.userFriendlyErrorDescription delegate: nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles: nil];
             [alert show];
             
             [cell resetAgreedDisagreed];
         }
     }];
}

- (void) predictionDisagreed: (Prediction*) prediction inCell: (PreditionCell*) cell
{
    PredictionDisagreeWebRequest* request = [[PredictionDisagreeWebRequest alloc] initWithPredictionID: prediction.ID];
    [request executeWithCompletionBlock: ^
     {
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
             UIAlertView* alert = [[UIAlertView alloc] initWithTitle: @"" message: request.userFriendlyErrorDescription delegate: nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles: nil];
             [alert show];
             
             [cell resetAgreedDisagreed];
         }
     }];
}

- (void) profileSelectedWithUserId:(NSInteger)userId inCell:(PreditionCell *)cell {
//    [self performSegueWithIdentifier:kUserProfileSegue sender:[NSNumber numberWithInteger:userId]];
}

@end
