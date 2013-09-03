//
//  ExpiredAlertsViewController.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/25/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "ExpiredAlertsViewController.h"

#import "ExpiredAlertsWebRequest.h"
#import "PredictionDetailsViewController.h"
#import "AlertCell.h"

static NSString* const kPredictionDetailsSegue = @"PredictionDetailsSegue";

@interface ExpiredAlertsViewController ()

@end

@implementation ExpiredAlertsViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self refresh];
}

- (void)refresh {
    
    __weak ExpiredAlertsViewController *weakSelf = self;
    
    ExpiredAlertsWebRequest* request = [[ExpiredAlertsWebRequest alloc] init];
    [request executeWithCompletionBlock: ^
     {
         ExpiredAlertsViewController *strongSelf = weakSelf;
         if(!strongSelf) {
             return;
         }
         if (request.errorCode == 0)
         {
             if (request.predictions.count > 0) {
                 NSLog(@"Expired alerts: %@", request.predictions);
                 
                 strongSelf.predictions = [NSMutableArray arrayWithArray:request.predictions];
                 [strongSelf.tableView reloadData];
             }
             else {
                 self.noContentView.hidden = NO;
             }
         }
     }];
}

- (void) prepareForSegue: (UIStoryboardSegue*) segue sender: (id) sender
{
    if([segue.identifier isEqualToString: kPredictionDetailsSegue]) {
        PredictionDetailsViewController *vc = (PredictionDetailsViewController *)segue.destinationViewController;
        vc.prediction = sender;
    }
}

- (NSInteger) numberOfSectionsInTableView: (UITableView*) tableView
{
    return 1;
}


- (NSInteger) tableView: (UITableView*) tableView numberOfRowsInSection: (NSInteger) section
{
    return (self.predictions.count == 0) ? 1 : self.predictions.count;
}


- (UITableViewCell*) tableView: (UITableView*) tableView cellForRowAtIndexPath: (NSIndexPath*) indexPath
{
    UITableViewCell* cell = nil;
    
    if (self.predictions.count != 0)
    {
        cell = [self.tableView dequeueReusableCellWithIdentifier: [AlertCell reuseIdentifier]];
        [((AlertCell*)cell) fillWithPrediction: [self.predictions objectAtIndex: indexPath.row]];
    }
    else
    {
        cell = [self.tableView dequeueReusableCellWithIdentifier: @"LoadingCell"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
    
    if (self.predictions.count != 0)
    {
        Prediction* prediction = [self.predictions objectAtIndex: indexPath.row];
        [self performSegueWithIdentifier:kPredictionDetailsSegue sender:prediction];
    }
}

@end
