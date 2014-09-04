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

@interface GroupSettingsViewController () <UITableViewDataSource, UITableViewDelegate, MemberTableViewCellDelegate, UIActionSheetDelegate>
@property (strong, nonatomic) Group *group;
@property (weak, nonatomic) IBOutlet UIImageView *groupImageView;
@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *groupDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIView *leaveGroupView;
@property (weak, nonatomic) IBOutlet UIView *inviteView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *editGroupView;
@property (weak, nonatomic) IBOutlet UIView *joinGroupView;
@property (strong, nonatomic) NSArray *members;
@property (strong, nonatomic) NSString *invitationCode;
@property (assign, nonatomic) BOOL modal;
@property (assign, nonatomic) CGRect originalDescriptionFrame;
@end

@implementation GroupSettingsViewController

- (id)initWithGroup:(Group *)group {
    self = [super initWithNibName:@"GroupSettingsViewController" bundle:[NSBundle mainBundle]];
    self.group = group;
    return self;
}

- (id)initWithNewlyCreatedGroup:(Group *)group {
    self = [self initWithGroup:group];
    self.modal = YES;
    return self;
}

- (id)initWithGroup:(Group *)group invitationCode:(NSString *)invitationCode {
    self = [self initWithGroup:group];
    self.invitationCode = invitationCode;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [Flurry logEvent: @"Group_Settings"];
    self.title = @"SETTINGS";
    self.originalDescriptionFrame = self.groupDescriptionLabel.frame;
    
    if (self.modal ) {
        [self.navigationItem setRightBarButtonItem:[UIBarButtonItem styledBarButtonItemWithTitle:@"Done" target:self action:@selector(dismiss) color:[UIColor whiteColor]]];
        [self.navigationItem setLeftBarButtonItem:nil];
        self.navigationItem.hidesBackButton = YES;
    } else
        [self.navigationItem setLeftBarButtonItem:[UIBarButtonItem backButtonWithTarget:self action:@selector(back)]];
    

    [self populate];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupChanged:) name:GroupChangedNotificationName object:nil];
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)populate {
    [[WebApi sharedInstance] getImage:self.group.avatar.small completion:^(UIImage *image, NSError *error) {
        if (!error && image)
            self.groupImageView.image = image;
    }];
    
    if (self.invitationCode && !self.group.myMembership) {
        self.inviteView.hidden = YES;
        self.editGroupView.hidden = YES;
        self.leaveGroupView.hidden = YES;
        self.joinGroupView.hidden = NO;
    } else {
        self.joinGroupView.hidden = YES;
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
        if (self.modal) {
            self.editGroupView.hidden = YES;
        }
    }
    
    self.groupNameLabel.text = self.group.name;
    self.groupDescriptionLabel.text = self.group.groupDescription;
    
    CGSize sizeThatFits = [self.groupDescriptionLabel sizeThatFits:self.originalDescriptionFrame.size];
    
    CGRect frame = self.originalDescriptionFrame;
    frame.size.height = sizeThatFits.height;
    self.groupDescriptionLabel.frame = frame;
    
    [self.groupDescriptionLabel sizeToFit];
    
    if (!self.invitationCode || self.group.myMembership)
        [self refresh];
}

- (void)refresh {
    [[WebApi sharedInstance] getMembersForGroup:self.group.groupId completion:^(NSArray *members, NSError *error) {
        if (!error) {
            self.members = members;
            [self.tableView reloadData];
        }
    }];
}

- (void)groupChanged:(NSNotification *)notification {
    Group *newGroup = [notification.userInfo objectForKey:GroupChangedNotificationKey];
    
    if (newGroup.groupId == self.group.groupId) {
        self.group = newGroup;
        [self populate];
        [self refresh];
    }
}
- (void)back {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)objectsAfterObject:(id)object completion:(void (^)(NSArray *, NSError *))completionHandler {
    completionHandler(nil, nil);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 44.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.members.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Member *member = [self.members objectAtIndex:indexPath.row];
    
    MemberTableViewCell *cell = [MemberTableViewCell cellForTableView:tableView delegate:self indexPath:indexPath];
    
    cell.nameLabel.text = member.username;
    
    BOOL isOwner = self.group.owner == [UserManager sharedInstance].user.userId && member.userId != [UserManager sharedInstance].user.userId;
    cell.removeButton.hidden = !isOwner;
    
    if (indexPath.row % 2 == 0)
        cell.backgroundColor = [UIColor whiteColor];
    else
        cell.backgroundColor = [UIColor colorFromHex:@"efefef"];
    
    return cell;
}

- (IBAction)leaveGroup:(id)sender {
    UIActionSheet * actionSheet = [[UIActionSheet alloc]initWithTitle:NSLocalizedString(@"Are you sure you want to leave?", @"") delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Leave group" otherButtonTitles:@"Cancel", nil];
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [[LoadingView sharedInstance] hide];
        
        [[WebApi sharedInstance] deleteMembership:self.group.myMembership completion:^(NSError *error) {
            [[UserManager sharedInstance] refreshUser:^(User *user, NSError *error) {
                [[LoadingView sharedInstance] hide];
                [self.navigationController popToRootViewControllerAnimated:YES];
            }];
        }];
    }
}
- (IBAction)joinGroup:(id)sender {
    
    [[LoadingView sharedInstance] show];
    
    [[WebApi sharedInstance] consumeInviteCode:self.invitationCode forGroup:self.group completion:^(Member *membership, NSError *error) {
        [[LoadingView sharedInstance] hide];
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Unable to join the group at this time." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        [[WebApi sharedInstance] getGroup:self.group.groupId completion:^(Group *group, NSError *error) {
            [[UserManager sharedInstance] refreshUser:^(User *user, NSError *error) {}];
            self.group = group;
            self.invitationCode = nil;
            [self populate];
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
    [self.view.window.rootViewController presentViewController:nav animated:YES completion:nil];
}

- (IBAction)shareLink:(id)sender {
    [Flurry logEvent: @"Group_Share_Link"];

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
    
    
    [self.view.window.rootViewController presentViewController:vc animated:YES completion:nil];
}

- (IBAction)editGroup:(id)sender {
    CreateGroupViewController *vc = [[CreateGroupViewController alloc] initWithGroup:self.group];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
