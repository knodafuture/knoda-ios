//
//  FollowersTableViewController.m
//  KnodaIPhoneApp
//
//  Created by nick on 9/1/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "FollowersTableViewController.h"
#import "FollowersTableViewCell.h"  
#import "WebApi.h"
#import "LoadingView.h"
#import "Follower.h"
#import "AnotherUsersProfileViewController.h"
#import "UserManager.h"
#import "SocialInvitationsViewController.h"

@interface FollowersTableViewController () <FollowersTableViewCellDelegate>
@property (assign, nonatomic) BOOL leader;
@property (assign, nonatomic) NSInteger userId;
@property (strong, nonatomic) IBOutlet UILabel *emptyLabel;
@end

@implementation FollowersTableViewController

- (id)initAsLeader:(BOOL)asLeader forUser:(NSInteger)userId {
    self = [super initWithStyle:UITableViewStylePlain];
    self.leader = asLeader;
    self.userId = userId;
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.separatorColor = [UIColor colorFromHex:@"efefef"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    
    self.tableView.tableFooterView = [[UIView alloc] init];
}

- (void)objectsAfterObject:(id)object completion:(void (^)(NSArray *, NSError *))completionHandler {
    if (self.leader) {
        [[WebApi sharedInstance] getFollowers:self.userId completion:completionHandler];
    } else {
        [[WebApi sharedInstance] getFollowing:self.userId completion:completionHandler];
    }
}

- (void)noObjectsRetrievedInPagingDatasource:(PagingDatasource *)pagingDatasource {
    UITableViewCell *cell = nil;
    if (self.leader) {
        if (self.userId == [UserManager sharedInstance].user.userId) {
            cell = [[[UINib nibWithNibName:@"EmptyCell" bundle:[NSBundle mainBundle]] instantiateWithOwner:self options:nil] lastObject];
            self.emptyLabel.text = @"You don't have any followers yet, but we know they're coming soon!";
        } else {
            cell = [[[UINib nibWithNibName:@"EmptyCell" bundle:[NSBundle mainBundle]] instantiateWithOwner:self options:nil] lastObject];
            self.emptyLabel.text = [NSString stringWithFormat:@"Be a sport and follow %@ so this list is no longer empty!", self.parentViewController.title];
        }
    } else {
        if (self.userId == [UserManager sharedInstance].user.userId) {
            cell = [[[UINib nibWithNibName:@"EmptyFollowersTableViewCell" bundle:[NSBundle mainBundle]] instantiateWithOwner:self options:nil] lastObject];
        } else {
            cell = [[[UINib nibWithNibName:@"EmptyCell" bundle:[NSBundle mainBundle]] instantiateWithOwner:self options:nil] lastObject];
            self.emptyLabel.text = [NSString stringWithFormat:@"%@ isn't following anyone yet. Maybe you'll be the first", self.parentViewController.title];
        }
    }
    
    [self showNoContent:cell];
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.pagingDatasource.objects.count)
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.pagingDatasource.objects.count)
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    FollowersTableViewCell *cell = [FollowersTableViewCell cellForTableView:self.tableView delegate:self indexPath:indexPath];
    
    User *user = self.pagingDatasource.objects[indexPath.row];
    
    UIImage *image = [_imageLoader lazyLoadImage:user.avatar.small onIndexPath:indexPath];
    if (image)
        cell.avatarImageView.image = image;
    else
        cell.avatarImageView.image = [UIImage imageNamed:@"NotificationAvatar"];
    
    [cell populate:user];
    
    return cell;
}

- (void)followButtonTappedInCell:(FollowersTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    User *user = [self.pagingDatasource.objects objectAtIndex:indexPath.row];
    
    [[LoadingView sharedInstance] show];
    
    if (user.followingId) {
        [[WebApi sharedInstance] unfollowUser:user.followingId.integerValue completion:^(NSError *error) {
            [self beginRefreshing];
            cell.following = NO;
            [[LoadingView sharedInstance] hide];
        }];
    } else {
        Follower *follower = [[Follower alloc] init];
        follower.leaderId = @(user.userId);
        [[WebApi sharedInstance] followUsers:@[follower] completion:^(NSArray *results, NSError *error) {
            [self beginRefreshing];
            cell.following = YES;
            [[LoadingView sharedInstance] hide];
        }];
    }
}

- (void)imageLoader:(ImageLoader *)loader finishedLoadingImage:(UIImage *)image forIndexPath:(NSIndexPath *)indexPath {
    FollowersTableViewCell *cell = (FollowersTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if (![cell isKindOfClass:FollowersTableViewCell.class])
        return;
    cell.avatarImageView.image = image;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row >= self.pagingDatasource.objects.count) {
        if (self.pagingDatasource.objects.count == 0) {
            SocialInvitationsViewController *vc = [[SocialInvitationsViewController alloc] init];
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            [self.view.window.rootViewController presentViewController:nav animated:YES completion:nil];
        }
        return;
    }
    User *user = [self.pagingDatasource.objects objectAtIndex:indexPath.row];
    
    
    AnotherUsersProfileViewController *vc = [[AnotherUsersProfileViewController alloc] initWithUserId:user.userId];
    
    [self.parentViewController.navigationController pushViewController:vc animated:YES];
}

@end
