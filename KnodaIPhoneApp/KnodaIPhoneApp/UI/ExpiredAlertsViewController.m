//
//  ExpiredAlertsViewController.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/25/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "ExpiredAlertsViewController.h"

#import "ExpiredAlertsWebRequest.h"
#import "AlertCell.h"

@interface ExpiredAlertsViewController ()

@property (nonatomic, strong) NSArray* alerts;
@property (nonatomic, strong) IBOutlet UITableView* tableView;

@end


@implementation ExpiredAlertsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	
    ExpiredAlertsWebRequest* request = [[ExpiredAlertsWebRequest alloc] init];
    [request executeWithCompletionBlock: ^
     {
         if (request.errorCode == 0)
         {
             NSLog(@"Expired alerts: %@", request.predictions);
             
             self.alerts = request.predictions;
             [self.tableView reloadData];
         }
     }];
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


@end
