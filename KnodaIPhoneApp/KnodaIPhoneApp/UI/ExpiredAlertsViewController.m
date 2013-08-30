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

@property (nonatomic, strong) NSArray* alerts;
@property (nonatomic, strong) IBOutlet UITableView* tableView;
@property (weak, nonatomic) IBOutlet UIView *noContentView;

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
                 
                 strongSelf.alerts = request.predictions;
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
    return (self.alerts.count == 0) ? 1 : self.alerts.count;
}


- (UITableViewCell*) tableView: (UITableView*) tableView cellForRowAtIndexPath: (NSIndexPath*) indexPath
{
    UITableViewCell* cell = nil;
    
    if (self.alerts.count != 0)
    {
        cell = [self.tableView dequeueReusableCellWithIdentifier: [AlertCell reuseIdentifier]];
        [((AlertCell*)cell) fillWithPrediction: [self.alerts objectAtIndex: indexPath.row]];
    }
    else
    {
        cell = [self.tableView dequeueReusableCellWithIdentifier: @"LoadingCell"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
    
    if (self.alerts.count != 0)
    {
        Prediction* prediction = [self.alerts objectAtIndex: indexPath.row];
        [self performSegueWithIdentifier:kPredictionDetailsSegue sender:prediction];
    }
}

@end
