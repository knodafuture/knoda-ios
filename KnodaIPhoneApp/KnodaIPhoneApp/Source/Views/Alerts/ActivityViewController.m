//
//  AlertsViewController.m
//  KnodaIPhoneApp
//
//  Created by nick on 12/11/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "ActivityViewController.h"
#import "AlertCell.h"
#import "NavigationViewController.h"
#import "WebApi.h"
#import "LoadingView.h"
#import "PredictionDetailsViewController.h"
#import "NoContentCell.h"
#import "ActivityItem+Utils.h"

@implementation ActivityViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"ACTIVITY";
    self.navigationController.navigationBar.translucent = NO;
}

- (void)menuPressed:(id)sender {
    [((NavigationViewController*)self.navigationController.parentViewController) toggleNavigationPanel];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self beginRefreshing];
    [Flurry logEvent:@"ActivityFeed" timed:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [Flurry endTimedEvent:@"ActivityFeed" withParameters:nil];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.pagingDatasource.objects.count)
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    
    return AlertCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.pagingDatasource.objects.count)
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    ActivityItem *alert = [self.pagingDatasource.objects objectAtIndex:indexPath.row];
    
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
        cell.contentView.backgroundColor = [UIColor colorFromHex:@"f9f9f9"];

    cell.iconImageView.image = [self imageForActivityItem:alert];
    cell.createdAtLabel.text = [alert creationString];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.pagingDatasource.objects.count)
        return;
    
    ActivityItem *alert = [self.pagingDatasource.objects objectAtIndex:indexPath.row];
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
    
    if (indexPath.row >= self.pagingDatasource.objects.count)
        return;
    
    ActivityItem *alert = [self.pagingDatasource.objects objectAtIndex:indexPath.row];
    
    alert.seen = YES;
}

- (void)noObjectsRetrievedInPagingDatasource:(PagingDatasource *)pagingDatasource {
    NoContentCell *cell = [NoContentCell noContentWithMessage:@"No Activity" forTableView:self.tableView];
    [self showNoContent:cell];
}

- (void)objectsAfterObject:(id)object completion:(void (^)(NSArray *, NSError *))completionHandler {
    NSInteger lastId = [(ActivityItem *)object activityItemId];
    [[WebApi sharedInstance] getActivityAfter:lastId completion:completionHandler];
}

- (UIImage *)imageForActivityItem:(ActivityItem *)item {
    switch (item.alertType) {
        case AlertTypeComment:
            return [UIImage imageNamed:@"ActivityCommentIcon"];
            break;
        case AlertTypeExpired:
            return [UIImage imageNamed:@"ActivityExpiredIcon"];
            break;
        case AlertTypeWon:
            return [UIImage imageNamed:@"ActivityWonIcon"];
            break;
        case AlertTypeLost:
            return [UIImage imageNamed:@"ActivityLostIcon"];
        default:
            return nil;
            break;
    }
}

@end
