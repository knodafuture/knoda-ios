//
//  AlertsViewController.m
//  KnodaIPhoneApp
//
//  Created by nick on 12/11/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "AlertsViewController.h"
#import "AlertCell.h"
#import "NavigationViewController.h"
#import "WebApi.h"
#import "LoadingView.h"
#import "PredictionDetailsViewController.h"

@interface AlertsViewController ()
@property (strong, nonatomic) NSMutableIndexSet *seenIds;

@end

@implementation AlertsViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"ALERTS";
    self.navigationController.navigationBar.translucent = NO;
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem addPredictionBarButtonItem];
    
    self.seenIds = [[NSMutableIndexSet alloc] init];
}

- (void)menuPressed:(id)sender {
    [((NavigationViewController*)self.navigationController.parentViewController) toggleNavigationPanel];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [Flurry logEvent:@"ActivityFeed" timed:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [Flurry endTimedEvent:@"ActivityFeed" withParameters:nil];
    
    [self sendSeenAlerts:nil];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.pagingDatasource.objects.count)
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    
    return AlertCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.pagingDatasource.objects.count)
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    Alert *alert = [self.pagingDatasource.objects objectAtIndex:indexPath.row];
    
    AlertCell *cell = [AlertCell alertCellForTableView:tableView];
    
    NSDictionary *titleAttributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:13.0]};
    NSDictionary *bodyAttributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0]};
    
    NSString *bodyString = [NSString stringWithFormat:@" \"%@\"", alert.predictionBody];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] init];
    [string appendAttributedString:[[NSAttributedString alloc] initWithString:alert.title attributes:titleAttributes]];
    [string appendAttributedString:[[NSAttributedString alloc] initWithString:bodyString attributes:bodyAttributes]];
    
    cell.bodyLabel.attributedText = string;
    
    if (alert.seen)
        cell.contentView.backgroundColor = [UIColor whiteColor];
    else
        cell.contentView.backgroundColor = [UIColor greenColor];//[UIColor colorFromHex:@"f9f9f9"];

    cell.iconImageView.image = [alert image];
    cell.createdAtLabel.text = alert.createdAtString;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.pagingDatasource.objects.count)
        return;
    
    Alert *alert = [self.pagingDatasource.objects objectAtIndex:indexPath.row];
    [[LoadingView sharedInstance] show];
    
    [[WebApi sharedInstance] getPrediction:alert.predictionId completion:^(Prediction *prediction, NSError *error) {
        [[LoadingView sharedInstance] hide];
        
        if (!error) {
            PredictionDetailsViewController *vc = [[PredictionDetailsViewController alloc] initWithPrediction:prediction];
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"An unknown error occured." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
        
    }];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    
    NSLog(@"%d", indexPath.row);
    if (indexPath.row >= self.pagingDatasource.objects.count)
        return;
    
    Alert *alert = [self.pagingDatasource.objects objectAtIndex:indexPath.row];
    
    if (alert.seen)
        return;
    
    alert.seen = YES;
        
    [self.seenIds addIndex:alert.alertId];
}

- (void)objectsAfterObject:(id)object completion:(void (^)(NSArray *, NSError *))completionHandler {
    NSInteger lastId = [(Alert *)object alertId];
    [[WebApi sharedInstance] getAlertsAfter:lastId completion:completionHandler];
}

- (void)beginRefreshing {
    [self sendSeenAlerts:^{
        self.pagingDatasource.currentPage = 0;
        [self.pagingDatasource loadPage:0 completion:^{
            [self endRefreshing];
        }];
    }];
}

- (void)sendSeenAlerts:(void(^)(void))completion {
    __block NSMutableArray *ids = [NSMutableArray arrayWithCapacity:self.pagingDatasource.objects.count];
    
    [self.seenIds enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [ids addObject:@(idx)];
    }];
    
    [[WebApi sharedInstance] setSeenAlerts:ids completion:^(NSError *error) {
        if (error)
            NSLog(@"error setting seen alerts");
        if (completion)
            completion();
    }];
}

@end
