//
//  SettingsTableViewController.m
//  KnodaIPhoneApp
//
//  Created by nick on 7/15/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "SettingsViewController.h"
#import "UserManager.h"
#import "AppDelegate.h"
#import "AboutViewController.h"
#import "NotificationSettingsViewController.h"
#import "ProfileViewController.h"

@interface SettingsViewController () <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UIButton *signOutButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"SETTINGS";
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem styledBarButtonItemWithTitle:@"Done" target:self action:@selector(done) color:[UIColor whiteColor]];
    self.tableView.tableFooterView = [[UIView alloc] init];
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    
    self.view.backgroundColor = [UIColor colorFromHex:@"efefef"];
    self.tableView.separatorColor = [UIColor colorFromHex:@"efefef"];
    
    [self.signOutButton setTitle:[NSString stringWithFormat:@"Log Out %@", [UserManager sharedInstance].user.name] forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CGRect frame = self.tableView.frame;
    frame.size = self.tableView.contentSize;
    self.tableView.frame = frame;

}

- (void)done {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"asd"];
    
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"asd"];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0];
        cell.textLabel.textColor = [UIColor colorFromHex:@"797979"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SettingsArrow"]];
        CGRect frame = imageView.frame;
        frame.origin.y = (cell.frame.size.height / 2.0) - (frame.size.height / 2.0);
        frame.origin.x = cell.frame.size.width - 10.0 - frame.size.width;
        imageView.frame = frame;
        
        [cell.contentView addSubview:imageView];
        
        frame = cell.textLabel.frame;
        frame.origin.x = 10.0;
        cell.textLabel.frame = frame;
    }
    
    if (indexPath.row == 0)
        cell.textLabel.text = @"Push Notifications";
    else if (indexPath.row == 1)
        cell.textLabel.text = @"Profile Settings";
    else if (indexPath.row == 2)
        cell.textLabel.text = @"About";
    else
        cell.textLabel.text = @"";
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        NotificationSettingsViewController *vc = [[NotificationSettingsViewController alloc] initWithStyle:UITableViewStylePlain];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (indexPath.row == 1) {
        ProfileViewController *vc = [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:[NSBundle mainBundle]];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (indexPath.row == 2) {
        AboutViewController *vc = [[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:[NSBundle mainBundle]];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)signOut:(id)sender {
    UIActionSheet * actionSheet = [[UIActionSheet alloc]initWithTitle:NSLocalizedString(@"Are you sure you want to log out?", @"") delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Log Out" otherButtonTitles:@"Cancel", nil];
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [[UserManager sharedInstance] signout:^(NSError *error) {
            [(AppDelegate *)[UIApplication sharedApplication].delegate logout];
        }];
    }
}
@end
