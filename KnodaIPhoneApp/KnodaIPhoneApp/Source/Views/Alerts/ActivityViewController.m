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
#import "NSString+Utils.h"
#import "GroupSettingsViewController.h"
#import "WinActivityTableViewCell.h"
#import "UserManager.h"

@implementation ActivityViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"ACTIVITY";
    self.navigationController.navigationBar.translucent = NO;
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
    
    return 140;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.pagingDatasource.objects.count)
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    ActivityItem *alert = [self.pagingDatasource.objects objectAtIndex:indexPath.row];
    
    if (alert.type == ActivityTypeWon) {
        WinActivityTableViewCell *cell = [WinActivityTableViewCell cellForTableView:tableView onIndexPath:indexPath delegate:nil];
        
        cell.avatarImageView.image = [_imageLoader lazyLoadImage:[UserManager sharedInstance].user.avatar.big onIndexPath:indexPath];
        
        cell.titleLabel.attributedText = [alert attributedText];
        
        return cell;
        
    } else {
    
        AlertCell *cell = [AlertCell alertCellForTableView:tableView];
        

        cell.bodyLabel.attributedText = [alert attributedText];
        
        cell.iconImageView.image = [self imageForActivityItem:alert];
        cell.createdAtLabel.text = [alert creationString];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.pagingDatasource.objects.count)
        return;
    
    ActivityItem *alert = [self.pagingDatasource.objects objectAtIndex:indexPath.row];
    [[LoadingView sharedInstance] show];
    
    if (alert.type != ActivityTypeInvitation) {
    
        [[WebApi sharedInstance] getPrediction:[alert.target integerValue] completion:^(Prediction *prediction, NSError *error) {
            [[LoadingView sharedInstance] hide];
            
            if (!error) {
                PredictionDetailsViewController *vc = [[PredictionDetailsViewController alloc] initWithPrediction:prediction];
                [self.navigationController pushViewController:vc animated:YES];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"An unknown error occured." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
            }
            
        }];
    } else {
        
        [[WebApi sharedInstance] getInvitationDetails:alert.target completion:^(InvitationCodeDetails *details, NSError *error) {
            [[LoadingView sharedInstance] hide];
            if (!error) {
                GroupSettingsViewController *vc = [[GroupSettingsViewController alloc] initWithGroup:details.group invitationCode:alert.target];
                [self.navigationController pushViewController:vc animated:YES];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"An unknown error occured." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
            }
        }];
    }
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
    switch (item.type) {
        case ActivityTypeComment:
            return [UIImage imageNamed:@"ActivityCommentIcon"];
            break;
        case ActivityTypeExpired:
            return [UIImage imageNamed:@"ActivityExpiredIcon"];
            break;
        case ActivityTypeWon:
            return [UIImage imageNamed:@"ActivityWonIcon"];
            break;
        case ActivityTypeLost:
            return [UIImage imageNamed:@"ActivityLostIcon"];
        case ActivityTypeInvitation:
            return [UIImage imageNamed:@"ActivityGroupsIcon"];
        default:
            return nil;
            break;
    }
}

- (void)imageLoader:(ImageLoader *)loader finishedLoadingImage:(UIImage *)image forIndexPath:(NSIndexPath *)indexPath {
    WinActivityTableViewCell *cell = (WinActivityTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if (![cell isKindOfClass:WinActivityTableViewCell.class])
        return;
    cell.avatarImageView.image = image;
}

@end
