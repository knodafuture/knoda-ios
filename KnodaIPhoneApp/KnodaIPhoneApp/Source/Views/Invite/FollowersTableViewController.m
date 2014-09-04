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

@interface FollowersTableViewController () <FollowersTableViewCellDelegate>
@property (assign, nonatomic) BOOL leader;
@property (assign, nonatomic) NSInteger userId;
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
        follower.leaderId = [NSString stringWithFormat:@"%ld", (long)user.userId];
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

@end
