//
//  AllAlertsViewController.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/25/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "AllAlertsViewController.h"

#import "AlertCell.h"
#import "AllAlertsWebRequest.h"


@interface AllAlertsViewController ()

@property (nonatomic, strong) NSArray* alerts;
@property (nonatomic, strong) IBOutlet UITableView* tableView;

@end

@implementation AllAlertsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	
    AllAlertsWebRequest* request = [[AllAlertsWebRequest alloc] init];
    [request executeWithCompletionBlock: ^
    {
        if (request.errorCode == 0)
        {
            NSLog(@"All alerts: %@", request.predictions);
            
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
        cell = [tableView dequeueReusableCellWithIdentifier: [AlertCell reuseIdentifier]];
        [((AlertCell*)cell) fillWithPrediction: [self.alerts objectAtIndex: indexPath.row]];
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier: @"LoadingCell"];
    }
    
    return cell;
}


@end
