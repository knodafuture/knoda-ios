//
//  GroupSettingsViewController.m
//  KnodaIPhoneApp
//
//  Created by nick on 3/19/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "GroupSettingsViewController.h"
#import "NoContentCell.h"
#import "WebApi.h"
#import "UserManager.h"
#import "InvitationsViewController.h"
#import "LoadingCell.h"
#import "MemberTableViewCell.h"
#import "CreateGroupViewController.h"
#import "LoadingView.h"

@interface GroupSettingsViewController () <UITableViewDataSource, UITableViewDelegate, MemberTableViewCellDelegate>
@property (strong, nonatomic) Group *group;
@property (weak, nonatomic) IBOutlet UIImageView *groupImageView;
@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *groupDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIView *leaveGroupView;
@property (weak, nonatomic) IBOutlet UIView *inviteView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *editGroupView;
@property (strong, nonatomic) NSArray *members;
@end

@implementation GroupSettingsViewController

- (id)initWithGroup:(Group *)group {
    self = [super initWithNibName:@"GroupSettingsViewController" bundle:[NSBundle mainBundle]];
    self.group = group;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"SETTINGS";
    [self.navigationItem setLeftBarButtonItem:[UIBarButtonItem backButtonWithTarget:self action:@selector(back)]];
    
    [[WebApi sharedInstance] getImage:self.group.avatar.small completion:^(UIImage *image, NSError *error) {
        if (!error && image)
            self.groupImageView.image = image;
    }];
    
    if ([UserManager sharedInstance].user.userId == self.group.owner) {
        self.inviteView.hidden = NO;
    } else {
        self.inviteView.hidden = YES;
        self.editGroupView.hidden = YES;
        CGRect frame = self.tableView.frame;
        frame.size.height = self.view.frame.size.height - frame.origin.y;
        self.tableView.frame = frame;
    }
    
    self.leaveGroupView.hidden = !self.inviteView.hidden;
    
    self.groupNameLabel.text = self.group.name;
    self.groupDescriptionLabel.text = self.group.groupDescription;
    
    CGSize sizeThatFits = [self.groupDescriptionLabel sizeThatFits:self.groupDescriptionLabel.frame.size];
    
    if (sizeThatFits.height < self.groupDescriptionLabel.frame.size.height) {
        CGRect frame = self.groupDescriptionLabel.frame;
        frame.size.height = sizeThatFits.height;
        self.groupDescriptionLabel.frame = frame;
    }
    
    [self.groupDescriptionLabel sizeToFit];
}

- (void)refresh {
    [[WebApi sharedInstance] getMembersForGroup:self.group.groupId completion:^(NSArray *members, NSError *error) {
        if (!error) {
            self.members = members;
            [self.tableView reloadData];
        }
    }];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)objectsAfterObject:(id)object completion:(void (^)(NSArray *, NSError *))completionHandler {
    completionHandler(nil, nil);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (!self.members)
        return loadingCellHeight;
    return 44.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!self.members)
        return 1;
    
    return self.members.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (!self.members)
        return [LoadingCell loadingCellForTableView:tableView];
    
    Member *member = [self.members objectAtIndex:indexPath.row];
    
    MemberTableViewCell *cell = [MemberTableViewCell cellForTableView:tableView delegate:self indexPath:indexPath];
    
    cell.nameLabel.text = member.username;
    
    if (indexPath.row % 2 == 0)
        cell.backgroundColor = [UIColor whiteColor];
    else
        cell.backgroundColor = [UIColor colorFromHex:@"efefef"];
    
    return cell;
}

- (IBAction)leaveGroup:(id)sender {
    [[LoadingView sharedInstance] hide];
    
    [[WebApi sharedInstance] deleteMembership:self.group.myMembership completion:^(NSError *error) {
        [[UserManager sharedInstance] refreshUser:^(User *user, NSError *error) {
            [[LoadingView sharedInstance] hide];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }];
    }];
}

- (void)MemberTableViewCell:(MemberTableViewCell *)cell didRemoveOnIndexPath:(NSIndexPath *)indexPath {
    
    Member *member = [self.members objectAtIndex:indexPath.row];
    
    [[WebApi sharedInstance] deleteMembership:member completion:^(NSError *error) {
        [self refresh];
    }];
}

- (IBAction)sendInvites:(id)sender {
    InvitationsViewController *vc = [[InvitationsViewController alloc] initWithGroup:self.group];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

- (IBAction)shareLink:(id)sender {
    NSString *message = [NSString stringWithFormat:@"Join my group %@ on Knoda! %@", self.group.name, self.group.shareUrl];
    UIActivityViewController *vc = [[UIActivityViewController alloc] initWithActivityItems:@[message] applicationActivities:nil];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
        [vc setExcludedActivityTypes:@[UIActivityTypePostToWeibo, UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo,
                                       UIActivityTypePostToFlickr, UIActivityTypeAssignToContact, UIActivityTypeAirDrop, UIActivityTypeAddToReadingList, UIActivityTypeSaveToCameraRoll, UIActivityTypePrint]];
    else
        [vc setExcludedActivityTypes:@[UIActivityTypePostToWeibo, UIActivityTypeAssignToContact, UIActivityTypePrint, UIActivityTypeSaveToCameraRoll]];
    [UINavigationBar setDefaultAppearance];
    
    [vc setCompletionHandler:^(NSString *act, BOOL done) {
        [UINavigationBar setCustomAppearance];
    }];
    
    [vc setValue:[NSString stringWithFormat:@"%@ invited you to join a group on Knoda", [UserManager sharedInstance].user.name] forKey:@"subject"];
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)editGroup:(id)sender {
    CreateGroupViewController *vc = [[CreateGroupViewController alloc] initWithGroup:self.group];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

@end
