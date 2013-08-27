//
//  HomeViewController.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/24/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "HomeViewController.h"
#import "NavigationViewController.h"
#import "ProfileViewController.h"
#import "PredictionsWebRequest.h"
#import "Prediction.h"
#import "AnotherUsersProfileViewController.h"
#import "PredictionAgreeWebRequest.h"
#import "PredictionDisagreeWebRequest.h"
#import "ChellangeByPredictionWebRequest.h"
#import "AppDelegate.h"
#import "PredictionDetailsViewController.h"
#import "User.h"

static NSString* const kPredictionDetailsSegue = @"PredictionDetailsSegue";
static NSString* const kAddPredictionSegue     = @"AddPredictionSegue";
static NSString* const kUserProfileSegue       = @"UserProfileSegue";
static NSString* const kMyProfileSegue         = @"MyProfileSegue";

@interface HomeViewController ()

@property (nonatomic, strong) NSMutableArray* predictions;
@property (nonatomic, strong) NSTimer* cellUpdateTimer;
@property (nonatomic, strong) AppDelegate * appDelegate;

@property (weak, nonatomic) IBOutlet UIView *noContentView;

@end

@implementation HomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	self.navigationController.navigationBar.frame = CGRectMake(0, 0, self.view.frame.size.width, self.navigationController.navigationBar.frame.size.height);
    
    [self refresh:nil];
    
    UIRefreshControl* refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget: self action: @selector(refresh:) forControlEvents: UIControlEventValueChanged];
    
    self.refreshControl = refreshControl;
}

- (void) setUpNoContentViewHidden: (BOOL) hidden {
    if (self.noContentView.hidden == hidden) {
        return;
    }
    
    self.noContentView.hidden = hidden;
    if (hidden) {
        [self.noContentView removeFromSuperview];
    }
    else {
        [self.view addSubview:self.noContentView];
    }
}

- (void) viewDidAppear: (BOOL) animated
{
    [super viewDidAppear: animated];
    
    self.cellUpdateTimer = [NSTimer scheduledTimerWithTimeInterval: 60.0 target: self selector: @selector(updateVisibleCells) userInfo: nil repeats: YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.cellUpdateTimer invalidate];
    self.cellUpdateTimer = nil;
}

- (void) updateVisibleCells
{
    NSArray* visibleCells = [self.tableView visibleCells];
    
    for (UITableViewCell* cell in visibleCells)
    {
        if([cell isKindOfClass:[PreditionCell class]]) {
            [(PreditionCell *)cell updateDates];
        }
    }
}


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
    else if([segue.identifier isEqualToString:kUserProfileSegue]) {
        AnotherUsersProfileViewController *vc = (AnotherUsersProfileViewController *)segue.destinationViewController;
        vc.userId = [sender integerValue];
    }
    else if([segue.identifier isEqualToString:kMyProfileSegue]) {
        ProfileViewController *vc = (ProfileViewController *)segue.destinationViewController;
        vc.leftButtonItemReturnsBack = YES;
    }
}

#pragma mark Override

- (NSString *)predictionsCategory {
    return nil;
}

#pragma mark - Actions


- (IBAction) menuButtonPressed: (id) sender
{
    [((NavigationViewController*)self.navigationController.parentViewController) toggleNavigationPanel];
}


- (void) refresh: (UIRefreshControl*) refresh
{
    __weak HomeViewController *weakSelf = self;
    
    PredictionsWebRequest* predictionsRequest = [[PredictionsWebRequest alloc] initWithOffset: 0 andTag:[self predictionsCategory]];
    [predictionsRequest executeWithCompletionBlock: ^
     {
         HomeViewController *strongSelf = weakSelf;
         if(!strongSelf) {
             return;
         }
         
         [refresh endRefreshing];
         
         if (predictionsRequest.errorCode == 0)
         {
             strongSelf.predictions = [NSMutableArray arrayWithArray: predictionsRequest.predictions];
             [strongSelf.tableView reloadData];
         }
         BOOL hideContentView = strongSelf.predictions.count > 0;
         [strongSelf setUpNoContentViewHidden:hideContentView];
     }];
}


#pragma mark - UITableViewDataSource


- (NSInteger) numberOfSectionsInTableView: (UITableView*) tableView
{
    return 1;
}


- (NSInteger) tableView: (UITableView*) tableView numberOfRowsInSection: (NSInteger) section
{
    return (self.predictions.count != 0) ? ((self.predictions.count >= [PredictionsWebRequest limitByPage]) ? self.predictions.count + 1 : self.predictions.count) : 1;
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
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]init];
        [cell setUpUserProfileTapGestures:tapGesture];
        tableCell = cell;
    }
    else
    {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: @"LoadingCell"];
        tableCell = cell;
    }
    return tableCell;
}


#pragma mark - UITableViewDelegate


- (void) tableView: (UITableView*) tableView willDisplayCell: (UITableViewCell*) cell forRowAtIndexPath: (NSIndexPath*) indexPath
{
    if ((self.predictions.count >= [PredictionsWebRequest limitByPage]) && indexPath.row == self.predictions.count)
    {
        __weak HomeViewController *weakSelf = self;
        
        PredictionsWebRequest* predictionsRequest = [[PredictionsWebRequest alloc] initWithLastID: ((Prediction*)[self.predictions lastObject]).ID andTag:[self predictionsCategory]];
        [predictionsRequest executeWithCompletionBlock: ^
         {
             HomeViewController *strongSelf = weakSelf;
             if(!strongSelf) {
                 return;
             }
             
             if (predictionsRequest.errorCode == 0 && predictionsRequest.predictions.count != 0)
             {
                 [strongSelf.predictions addObjectsFromArray: [NSMutableArray arrayWithArray: predictionsRequest.predictions] ];
                 [strongSelf.tableView reloadData];
             }
             else
             {
                 [strongSelf.tableView scrollToRowAtIndexPath: [NSIndexPath indexPathForRow: indexPath.row - 1 inSection: 0] atScrollPosition: UITableViewScrollPositionBottom animated: YES];
             }
         }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.predictions.count != 0)
    {
        Prediction* prediction = [self.predictions objectAtIndex: indexPath.row];
        [self performSegueWithIdentifier:kPredictionDetailsSegue sender:prediction];
    }
}

#pragma mark - AddPredictionViewControllerDelegate


- (void) predictionWasMadeInController:(AddPredictionViewController *)vc
{
    [vc dismissViewControllerAnimated:YES completion:nil];
    
    [self refresh:nil];
}


#pragma mark - PredictionCellDelegate


- (void) predictionAgreed: (Prediction*) prediction inCell: (PreditionCell*) cell
{
    __weak HomeViewController *weakSelf = self;
    
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
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle: @"" message: request.userFriendlyErrorDescription delegate: nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles: nil];
            [alert show];
            
            [cell resetAgreedDisagreed];
        }
    }];
}

- (void) predictionDisagreed: (Prediction*) prediction inCell: (PreditionCell*) cell
{
    __weak HomeViewController *weakSelf = self;
    
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
             UIAlertView* alert = [[UIAlertView alloc] initWithTitle: @"" message: request.userFriendlyErrorDescription delegate: nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles: nil];
             [alert show];
             
             [cell resetAgreedDisagreed];
         }
     }];
}

- (void) profileSelectedWithUserId:(NSInteger)userId inCell:(PreditionCell *)cell {
    if (self.appDelegate.user.userId == userId) {
        [self performSegueWithIdentifier:kMyProfileSegue sender:self];
    }
    else {
        [self performSegueWithIdentifier:kUserProfileSegue sender:[NSNumber numberWithInteger:userId]];
    }
}

#pragma mark - AppDelegate

- (AppDelegate*) appDelegate
{
    return [UIApplication sharedApplication].delegate;
}

@end
