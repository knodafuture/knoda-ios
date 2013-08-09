//
//  HomeViewController.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/24/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "HomeViewController.h"
#import "NavigationViewController.h"
#import "PreditionCell.h"

#import "PredictionsWebRequest.h"
#import "Prediction.h"

#import "PredictionDetailsViewController.h"


@interface HomeViewController ()

@property (nonatomic, strong) NSMutableArray* predictions;

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


- (void) prepareForSegue: (UIStoryboardSegue*) segue sender: (id) sender
{
    if ([segue.identifier isEqualToString: @"AddPredictionSegue"])
    {
        ((AddPredictionViewController*)segue.destinationViewController).delegate = self;
    }
    else if ([segue.identifier isEqualToString: @"PredicionDetailsSegue"])
    {
        NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
        
        [self.tableView deselectRowAtIndexPath: indexPath animated: YES];
        ((PredictionDetailsViewController*)segue.destinationViewController).prediction = [self.predictions objectAtIndex: indexPath.row];
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


#pragma mark -


- (NSString*) predictionCreatedIntervalString: (Prediction*) prediciton
{
    NSString* result;
    
    NSDate* now = [NSDate date];
    
    NSTimeInterval interval = [now timeIntervalSinceDate: prediciton.creationDate];
    
    NSInteger secondsInMinute = 60;
    NSInteger minutesInHour = 60;
    NSInteger hoursInDay = 24;
    NSInteger daysInMonth = 30;
    NSInteger monthInYear = 12;
    
    if (interval < secondsInMinute)
    {
        result = [NSString stringWithFormat: NSLocalizedString(@"made %ds ago", @""), (NSInteger)interval];
    }
    else if (interval < (secondsInMinute * minutesInHour * hoursInDay))
    {
        NSInteger minutes = ((NSInteger)interval / secondsInMinute) % minutesInHour;
        NSInteger hours = (NSInteger)interval / (secondsInMinute * minutesInHour);
        
        NSString* hoursString = (hours != 0) ? [NSString stringWithFormat: NSLocalizedString(@"%dh", @""), hours] : @"";
        NSString* minutesString = (minutes != 0) ? [NSString stringWithFormat: NSLocalizedString(@"%dm", @""), minutes] : @"";
        NSString* space = (hours != 0 && minutes != 0) ? @" " : @"";
        
        result = [NSString stringWithFormat: NSLocalizedString(@"made %@%@%@ ago", @""), hoursString, space, minutesString];
    }
    else if (interval < (secondsInMinute * minutesInHour * hoursInDay * daysInMonth))
    {
        NSInteger days = ((NSInteger)interval / (secondsInMinute * minutesInHour * hoursInDay));
        result = [NSString stringWithFormat: NSLocalizedString(@"made %dd ago", @""), days];
    }
    else if (interval < (secondsInMinute * minutesInHour * hoursInDay * daysInMonth * monthInYear))
    {
        NSInteger month = ((NSInteger)interval / (secondsInMinute * minutesInHour * hoursInDay * daysInMonth));
        result = [NSString stringWithFormat: NSLocalizedString(@"made %dmth ago", @""), month];
    }
    else
    {
        NSInteger year = ((NSInteger)interval / (secondsInMinute * minutesInHour * hoursInDay * daysInMonth * monthInYear));
        result = [NSString stringWithFormat: NSLocalizedString(@"made %dyr%@ ago", @""), year, (year != 1) ? @"s" : @""];
    }
    
    return result;
}


- (NSString*) predictionExpiresIntervalString: (Prediction*) prediciton
{
    NSString* result;
    
    NSTimeInterval interval = 0;
    NSDate* now = [NSDate date];
    BOOL expired = NO;
    
    if ([now compare: prediciton.expirationDate] == NSOrderedAscending)
    {
        interval = [prediciton.expirationDate timeIntervalSinceDate: now];
    }
    else
    {
        interval = [now timeIntervalSinceDate: prediciton.expirationDate];
        expired = YES;
    }
    
    NSInteger secondsInMinute = 60;
    NSInteger minutesInHour = 60;
    NSInteger hoursInDay = 24;
    NSInteger daysInMonth = 30;
    NSInteger monthInYear = 12;
    
    if (interval < secondsInMinute)
    {
        result = [NSString stringWithFormat: NSLocalizedString(@"exp %ds%@", @""), (NSInteger)interval, (expired) ? @" ago" : @""];
    }
    else if (interval < (secondsInMinute * minutesInHour * hoursInDay))
    {
        NSInteger minutes = ((NSInteger)interval / secondsInMinute) % minutesInHour;
        NSInteger hours = (NSInteger)interval / (secondsInMinute * minutesInHour);
        
        NSString* hoursString = (hours != 0) ? [NSString stringWithFormat: NSLocalizedString(@"%dh", @""), hours] : @"";
        NSString* minutesString = (minutes != 0) ? [NSString stringWithFormat: NSLocalizedString(@"%dm", @""), minutes] : @"";
        NSString* space = (hours != 0 && minutes != 0) ? @" " : @"";
        
        result = [NSString stringWithFormat: NSLocalizedString(@"exp %@%@%@%@", @""), hoursString, space, minutesString, (expired) ? @" ago" : @""];
    }
    else if (interval < (secondsInMinute * minutesInHour * hoursInDay * daysInMonth))
    {
        NSInteger days = ((NSInteger)interval / (secondsInMinute * minutesInHour * hoursInDay)) + 1;
        result = [NSString stringWithFormat: NSLocalizedString(@"exp %dd%@", @""), days, (expired) ? @" ago" : @""];
    }
    else if (interval < (secondsInMinute * minutesInHour * hoursInDay * daysInMonth * monthInYear))
    {
        NSInteger month = ((NSInteger)interval / (secondsInMinute * minutesInHour * hoursInDay * daysInMonth)) + 1;
        result = [NSString stringWithFormat: NSLocalizedString(@"exp %dmth%@", @""), month, (expired) ? @" ago" : @""];
    }
    else
    {
        NSInteger year = ((NSInteger)interval / (secondsInMinute * minutesInHour * hoursInDay * daysInMonth * monthInYear)) + 1;
        result = [NSString stringWithFormat: NSLocalizedString(@"exp %dyr%@", @""), year, (year != 1) ? @"s" : @"", (expired) ? @" ago" : @""];
    }
    
    return result;
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
        
        PreditionCell* cell = [tableView dequeueReusableCellWithIdentifier: @"Cell"];
        
        cell.usernameLabel.text = prediction.userName;
        cell.bodyLabel.text = prediction.body;
        cell.metadataLabel.text = [NSString stringWithFormat: NSLocalizedString(@"%@ | %@ | %d%% agree", @""),
                                   [self predictionExpiresIntervalString: prediction],
                                   [self predictionCreatedIntervalString: prediction],
                                   prediction.agreedPercent];
        
        CGRect rect = cell.bodyLabel.frame;
        CGSize maximumLabelSize = CGSizeMake(218, 37);
        
        CGSize expectedLabelSize = [cell.bodyLabel.text sizeWithFont:[UIFont fontWithName: @"HelveticaNeue" size: 15] constrainedToSize:maximumLabelSize lineBreakMode:NSLineBreakByWordWrapping];
        rect.size.height = expectedLabelSize.height;
        cell.bodyLabel.frame = rect;
        
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


@end
