//
//  HomeViewController.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/24/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "HomeViewController.h"
#import "NavigationViewController.h"

#import "PredictionsWebRequest.h"
#import "Prediction.h"

#import "PredictionAgreeWebRequest.h"
#import "PredictionDisagreeWebRequest.h"
#import "ChellangeByPredictionWebRequest.h"

#import "PredictionDetailsViewController.h"

static NSString* const kPredictionDetailsSegue = @"PredictionDetailsSegue";
static NSString* const kAddPredictionSegue     = @"AddPredictionSegue";

@interface HomeViewController ()

@property (nonatomic, strong) NSMutableArray* predictions;
@property (nonatomic, strong) NSTimer* cellUpdateTimer;

@end



@implementation HomeViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
	self.navigationController.navigationBar.frame = CGRectMake(0, 0, self.view.frame.size.width, self.navigationController.navigationBar.frame.size.height);
    
    PredictionsWebRequest* predictionsRequest = [[PredictionsWebRequest alloc] initWithOffset: 0];
    [predictionsRequest executeWithCompletionBlock: ^
    {
        if (predictionsRequest.errorCode == 0)
        {
            self.predictions = [NSMutableArray arrayWithArray: predictionsRequest.predictions];
            [self.tableView reloadData];
        }
    }];
    
    UIRefreshControl* refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget: self action: @selector(refresh:) forControlEvents: UIControlEventValueChanged];
    
    self.refreshControl = refreshControl;
}


- (void) viewDidAppear: (BOOL) animated
{
    [super viewDidAppear: animated];
    
    self.cellUpdateTimer = [NSTimer scheduledTimerWithTimeInterval: 60.0 target: self selector: @selector(updateVisibleCells) userInfo: nil repeats: YES];
}


- (void) viewWillDisappear: (BOOL) animated
{
    [self.cellUpdateTimer invalidate];
    self.cellUpdateTimer = nil;
    
    [super viewWillDisappear: animated];
}

- (void) updateVisibleCells
{
    NSArray* visibleCells = [self.tableView visibleCells];
    
    for (PreditionCell* cell in visibleCells)
    {
        [cell updateDates];
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
    }
}


#pragma mark - Actions


- (IBAction) menuButtonPressed: (id) sender
{
    [((NavigationViewController*)self.navigationController.parentViewController) toggleNavigationPanel];
}


- (void) refresh: (UIRefreshControl*) refresh
{
    PredictionsWebRequest* predictionsRequest = [[PredictionsWebRequest alloc] initWithOffset: 0];
    [predictionsRequest executeWithCompletionBlock: ^
     {
         [refresh endRefreshing];
         
         if (predictionsRequest.errorCode == 0)
         {
             self.predictions = [NSMutableArray arrayWithArray: predictionsRequest.predictions];
             [self.tableView reloadData];
         }
     }];
}


#pragma mark - UITableViewDataSource


- (NSInteger) numberOfSectionsInTableView: (UITableView*) tableView
{
    return 1;
}


- (NSInteger) tableView: (UITableView*) tableView numberOfRowsInSection: (NSInteger) section
{
    return (self.predictions.count != 0) ? ((self.predictions.count >= [PredictionsWebRequest limitByPage]) ? self.predictions.count + 1 : self.predictions.count) : 0;
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


#pragma mark - UITableViewDelegate


- (void) tableView: (UITableView*) tableView willDisplayCell: (UITableViewCell*) cell forRowAtIndexPath: (NSIndexPath*) indexPath
{
    if (indexPath.row == self.predictions.count)
    {
        PredictionsWebRequest* predictionsRequest = [[PredictionsWebRequest alloc] initWithLastID: ((Prediction*)[self.predictions lastObject]).ID];
        [predictionsRequest executeWithCompletionBlock: ^
         {
             if (predictionsRequest.errorCode == 0 && predictionsRequest.predictions.count != 0)
             {
                 [self.predictions addObjectsFromArray: [NSMutableArray arrayWithArray: predictionsRequest.predictions] ];
                 [self.tableView reloadData];
             }
             else
             {
                 [self.tableView scrollToRowAtIndexPath: [NSIndexPath indexPathForRow: indexPath.row - 1 inSection: 0] atScrollPosition: UITableViewScrollPositionBottom animated: YES];
             }
         }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Prediction* prediction = [self.predictions objectAtIndex: indexPath.row];
    [self performSegueWithIdentifier:kPredictionDetailsSegue sender:prediction];
}

#pragma mark - AddPredictionViewControllerDelegate


- (void) predictinMade
{
    [self dismissViewControllerAnimated: YES completion: nil];
    
    PredictionsWebRequest* predictionsRequest = [[PredictionsWebRequest alloc] initWithOffset: 0];
    [predictionsRequest executeWithCompletionBlock: ^
     {
         if (predictionsRequest.errorCode == 0)
         {
             self.predictions = [NSMutableArray arrayWithArray: predictionsRequest.predictions];
             [self.tableView reloadData];
         }
     }];
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
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle: @"" message: NSLocalizedString(@"Unable to agree this prediction at this time. Please try again later.", @"") delegate: nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles: nil];
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
             UIAlertView* alert = [[UIAlertView alloc] initWithTitle: @"" message: NSLocalizedString(@"Unable to disagree this prediction at this time. Please try again later.", @"") delegate: nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles: nil];
             [alert show];
             
             [cell resetAgreedDisagreed];
         }
     }];
}


@end
