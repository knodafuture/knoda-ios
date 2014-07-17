//
//  AlertsViewController.m
//  KnodaIPhoneApp
//
//  Created by nick on 12/11/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "ActivityViewController.h"
#import "NavigationViewController.h"
#import "WebApi.h"
#import "LoadingView.h"
#import "PredictionDetailsViewController.h"
#import "NoContentCell.h"
#import "ActivityItem+Utils.h"
#import "NSString+Utils.h"
#import "GroupSettingsViewController.h"
#import "ResultActivityTableViewCell.h"
#import "UserManager.h"
#import "CommentActivityTableViewCell.h"
#import "SettleActivityTableViewCell.h"
#import "InviteActivityTableViewCell.h"
#import "UIActionSheet+Blocks.h"
#import "FacebookManager.h"
#import "UserManager.h"
#import "BragItemProvider.h"

@interface ActivityViewController () <ResultActivityTableViewCellDelegate, NavigationViewControllerDelegate>
@property (strong, nonatomic) NSString *filter;
@property (strong, nonatomic) Prediction *predictionToShare;
@end

@implementation ActivityViewController

- (id)initWithFilter:(NSString *)filter {
    self = [super initWithStyle:UITableViewStylePlain];
    self.filter = filter;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"ACTIVITY";
    self.navigationController.navigationBar.translucent = NO;
    
    self.tableView.separatorColor = [UIColor colorFromHex:@"efefef"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 6, 0, 0)];
    }
    
    self.tableView.scrollsToTop = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [Flurry logEvent:@"ActivityFeed" timed:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.pagingDatasource.objects.count)
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    
    ActivityItem *item = self.pagingDatasource.objects[indexPath.row];
    
    if (item.type == ActivityTypeWon || item.type == ActivityTypeLost)
        return [ResultActivityTableViewCell heightForActivityItem:item];
    
    if (item.type == ActivityTypeComment)
        return [CommentActivityTableViewCell heightForActivityItem:item];
    
    if (item.type == ActivityTypeExpired)
        return [SettleActivityTableViewCell heightForActivityItem:item];
    
    return 81;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.pagingDatasource.objects.count)
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    ActivityItem *alert = [self.pagingDatasource.objects objectAtIndex:indexPath.row];
    
    if (alert.type == ActivityTypeWon || alert.type == ActivityTypeLost) {
        ResultActivityTableViewCell *cell = [ResultActivityTableViewCell cellForTableView:tableView delegate:self];
        
        UIImage *image = [_imageLoader lazyLoadImage:alert.imageUrl onIndexPath:indexPath];
        if (image)
            cell.avatarImageView.image = image;
        else
            cell.avatarImageView.image = [UIImage imageNamed:@"NotificationAvatar"];
        [cell populate:alert];
        
        return cell;
        
    } else if (alert.type == ActivityTypeComment) {
        
        CommentActivityTableViewCell *cell = [CommentActivityTableViewCell cellForTableView:tableView];
        
        UIImage *image = [_imageLoader lazyLoadImage:alert.imageUrl onIndexPath:indexPath];
        if (image)
            cell.avatarImageView.image = image;
        else
            cell.avatarImageView.image = [UIImage imageNamed:@"NotificationAvatar"];
        [cell populate:alert];
        
        return cell;
        
    } else if (alert.type == ActivityTypeExpired) {
        SettleActivityTableViewCell *cell = [SettleActivityTableViewCell cellForTableView:tableView];
        [cell populate:alert];
        return cell;
    } else {
    
        InviteActivityTableViewCell *cell = [InviteActivityTableViewCell cellForTableView:tableView];
        [cell populate:alert];
        
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
    NoContentCell *cell = [NoContentCell noContentWithMessage:@"Sorry, you don't have any activity to view.\nGet things started and make a prediction." forTableView:self.tableView];
    [self showNoContent:cell];
}

- (void)objectsAfterObject:(id)object completion:(void (^)(NSArray *, NSError *))completionHandler {
    NSInteger lastId = [(ActivityItem *)object activityItemId];
    [[WebApi sharedInstance] getActivityAfter:lastId filter:self.filter completion:completionHandler];
}

- (void)imageLoader:(ImageLoader *)loader finishedLoadingImage:(UIImage *)image forIndexPath:(NSIndexPath *)indexPath {
    id cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (![cell respondsToSelector:@selector(avatarImageView)])
        return;
    
    UIImageView *imageView = [cell avatarImageView];
    imageView.image = image;
}

- (void)resultActivityTableViewCell:(ResultActivityTableViewCell *)cell didBragForActivityItem:(ActivityItem *)activityItem {
    
    [[WebApi sharedInstance] getPrediction:[activityItem.target intValue] completion:^(Prediction *prediction, NSError *error) {
        if (prediction.groupName) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Hold on, this is a private group prediction. You won't be able to share it with the world." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
            return;
        }
        self.predictionToShare = prediction;
        
        if (![UserManager sharedInstance].user.facebookAccount && ![UserManager sharedInstance].user.twitterAccount) {
            [self showDefaultShare];
            return;
        }
        
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"How would you like to share?" delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        for (SocialAccount *account in [UserManager sharedInstance].user.socialAccounts) {
            [sheet addButtonWithTitle:account.providerName.capitalizedString];
        }
        
        [sheet addButtonWithTitle:@"Other"];
        __unsafe_unretained ActivityViewController *this = self;
        sheet.tapBlock = ^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
            if (buttonIndex == actionSheet.destructiveButtonIndex)
                return;
            
            if (buttonIndex == [UserManager sharedInstance].user.socialAccounts.count)
                [this showDefaultShare];
            else
                [this shareWithSocialAccount:[UserManager sharedInstance].user.socialAccounts[buttonIndex]];
            
        };
        sheet.destructiveButtonIndex = [sheet addButtonWithTitle:@"Cancel"];
        [sheet showInView:[UIApplication sharedApplication].keyWindow];
    }];
    

}

- (void)shareWithSocialAccount:(SocialAccount *)account {
    [[LoadingView sharedInstance] show];
    if ([account.providerName isEqualToString:@"twitter"])
        [[WebApi sharedInstance] postPredictionToTwitter:self.predictionToShare brag:YES completion:^(NSError *error){
            [[LoadingView sharedInstance] hide];
            if (error) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"An unknown error occured." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
            }
        }];
    else if ([account.providerName isEqualToString:@"facebook"])
        [[FacebookManager sharedInstance] share:self.predictionToShare brag:YES completion:^(NSError *error){
            [[LoadingView sharedInstance] hide];
            if (error) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"An unknown error occured." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
            }
        }];
    
}

- (void)showDefaultShare {
    BragItemProvider *item = [[BragItemProvider alloc] initWithPrediction:self.predictionToShare];
    UIActivityViewController *vc = [[UIActivityViewController alloc] initWithActivityItems:@[item] applicationActivities:nil];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
        [vc setExcludedActivityTypes:@[UIActivityTypePostToWeibo, UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo,
                                       UIActivityTypePostToFlickr, UIActivityTypeAssignToContact, UIActivityTypeAirDrop, UIActivityTypeAddToReadingList, UIActivityTypeSaveToCameraRoll, UIActivityTypePrint]];
    else
        [vc setExcludedActivityTypes:@[UIActivityTypePostToWeibo, UIActivityTypeAssignToContact, UIActivityTypePrint, UIActivityTypeSaveToCameraRoll]];
    [UINavigationBar setDefaultAppearance];
    
    [vc setCompletionHandler:^(NSString *act, BOOL done) {
        [UINavigationBar setCustomAppearance];
    }];
    
    [vc setValue:[NSString stringWithFormat:@"%@ shared a Knoda prediction with you", [UserManager sharedInstance].user.name] forKey:@"subject"];
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)viewDidDisappearInNavigationViewController:(NavigationViewController *)viewController {
}

- (void)viewDidAppearInNavigationViewController:(NavigationViewController *)viewController {
    [self beginRefreshing];
}

@end
