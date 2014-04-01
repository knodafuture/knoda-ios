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

@interface RankingsTableViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSString *leaderBoardLocation;
@property (strong, nonatomic) Group *group;
@property (strong, nonatomic) NSArray *leaders;
@end

@implementation RankingsTableViewController


- (id)initWithGroup:(Group *)group location:(NSString *)location {
    self = [super initWithStyle:UITableViewStylePlain];
    self.group = group;
    self.leaderBoardLocation = location;
    return self;

}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self refresh];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
    return 36.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Leader *leader = [self.leaders objectAtIndex:indexPath.row];
    
    RankingsTableViewCell *cell = [RankingsTableViewCell cellForTableView:tableView];
    
    cell.rankLabel.text = [NSString stringWithFormat:@"%ld", (long)leader.rank];
    cell.usernameLabel.text = leader.username;
    cell.winLossLabel.text = [NSString stringWithFormat:@"%ld-%ld", (long)leader.won, (long)leader.lost];
    double total = leader.won + leader.lost;
    if (total > 0) {
        double percent = (double)leader.won / total * 100.0;
        if (percent == 100.0)
            cell.winPercentLabel.text = @"100%";
        else
            cell.winPercentLabel.text = [NSString stringWithFormat:@"%2.2f%%", percent];
    }
    else
        cell.winPercentLabel.text = @"-";
    
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



@end
