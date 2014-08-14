//
//  RankingsTableViewController.m
//  KnodaIPhoneApp
//
//  Created by nick on 3/24/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "RankingsTableViewController.h"
#import "RankingsTableViewCell.h"
#import "WebApi.h"
#import "ImageLoader.h"

@interface RankingsTableViewController () <UITableViewDataSource, UITableViewDelegate, ImageLoaderDelegate>

@property (strong, nonatomic) NSString *leaderBoardLocation;
@property (strong, nonatomic) Group *group;
@property (strong, nonatomic) ImageLoader *imageLoader;
@end

@implementation RankingsTableViewController

- (id)init {
    self = [super initWithStyle:UITableViewStylePlain];
    return self;
}

- (id)initWithGroup:(Group *)group location:(NSString *)location {
    self = [self init];
    self.group = group;
    self.leaderBoardLocation = location;
    return self;

}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self refresh];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.imageLoader = [[ImageLoader alloc] initForTable:self.tableView delegate:self];
}


- (void)refresh {
    NSLog(@"%ld", (long)self.group.groupId);
    [[WebApi sharedInstance] getLeaderBoardForGroup:self.group.groupId location:self.leaderBoardLocation completion:^(NSArray *leaders, NSError *error) {
        if (!error)
            self.leaders = leaders;
        [self.tableView reloadData];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.leaders.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Leader *leader = [self.leaders objectAtIndex:indexPath.row];
    
    RankingsTableViewCell *cell = [RankingsTableViewCell cellForTableView:tableView];
    
    cell.rankLabel.text = [NSString stringWithFormat:@"%ld", (long)leader.rank];
    cell.usernameLabel.text = leader.username;
    cell.winsLabel.text = [NSString stringWithFormat:@"%ld", (long)leader.won];
    
    cell.avatarImageView.image = [self.imageLoader lazyLoadImage:leader.avatar.big onIndexPath:indexPath];
    
    if (!leader.verifiedAccount)
        cell.verifiedCheckmark.hidden = YES;
    else {
        cell.verifiedCheckmark.hidden = NO;
        
        CGSize usernameSize = [cell.usernameLabel sizeThatFits:cell.usernameLabel.frame.size];
        CGRect frame = cell.verifiedCheckmark.frame;
        frame.origin.x = cell.usernameLabel.frame.origin.x + usernameSize.width + 5.0;
        cell.verifiedCheckmark.frame = frame;
    }
    
    if (indexPath.row % 2 != 0)
        cell.backgroundColor = [UIColor colorFromHex:@"efefef"];
    else
        cell.backgroundColor = [UIColor whiteColor];
    
    return cell;
    
}

- (void)imageLoader:(ImageLoader *)loader finishedLoadingImage:(UIImage *)image forIndexPath:(NSIndexPath *)indexPath {
    RankingsTableViewCell *cell = (RankingsTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    cell.avatarImageView.image = image;
}

- (UIImage *)imageLoader:(ImageLoader *)loader willCacheImage:(UIImage *)image forIndexPath:(NSIndexPath *)indexPath {
    return image;
}



@end
