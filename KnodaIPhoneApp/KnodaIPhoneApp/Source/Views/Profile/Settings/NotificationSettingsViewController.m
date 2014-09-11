//
//  NotificationSettingsViewController.m
//  KnodaIPhoneApp
//
//  Created by Grant Isom on 6/18/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "NotificationSettingsViewController.h"
#import "NotificationSettingsTableViewCell.h"
#import "WebApi.h"
#import "NotificationSettings.h"
#import "LoadingView.h"

@interface NotificationSettingsViewController ()

@property (strong, nonatomic) NSArray *settings;

@end

@implementation NotificationSettingsViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backButtonWithTarget:self action:@selector(back)];
    self.title = @"PUSH NOTIFICATIONS";
    if (self.tableView.contentSize.height < self.tableView.frame.size.height) {
        self.tableView.scrollEnabled = NO;
    }
    else {
        self.tableView.scrollEnabled = YES;
    }
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    self.tableView.separatorColor = [UIColor colorFromHex:@"efefef"];
    
    self.tableView.backgroundColor = [UIColor colorFromHex:@"efefef"];
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self refresh];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)refresh {
    [[WebApi sharedInstance] getSettingsCompletion:^(NSArray *settings, NSError *error) {
        self.settings = settings;
        [self.tableView reloadData];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.settings.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger ret = [self.settings[section] settings].count;
    return ret;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NotificationSettingsTableViewCell *cell = [NotificationSettingsTableViewCell cellForTableView:tableView];
    
    Settings *settings = self.settings[indexPath.section];
    
    NotificationSettings *setting = settings.settings[indexPath.row];
    
    cell.displayName.text = [setting displayName];
    cell.descriptionView.text = [setting settingDescription];
    [cell.descriptionView sizeToFit];
    
    CGFloat totalHeight = cell.descriptionView.frame.origin.y + cell.descriptionView.frame.size.height - cell.displayName.frame.origin.y;
    
    CGFloat spacing = cell.descriptionView.frame.origin.y - (cell.displayName.frame.origin.y + cell.displayName.frame.size.height);
    
    CGFloat center = (cell.frame.size.height / 2.0);
    
    CGRect frame = cell.displayName.frame;
    frame.origin.y = center - (totalHeight / 2.0);
    cell.displayName.frame = frame;
    
    frame = cell.descriptionView.frame;
    frame.origin.y = cell.displayName.frame.origin.y + cell.displayName.frame.size.height + spacing;
    cell.descriptionView.frame = frame;
    
    cell.switchIndicator.on = [setting active];
    cell.switchIndicator.tag = indexPath.row;
    cell.notificationSettings = setting;
    cell.delegate = self;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 62.0;
}

- (void)settingsChanged:(NotificationSettings *)notificationSetting inCell:(NotificationSettingsTableViewCell *)cell {
    
    if(notificationSetting.active){
        notificationSetting.active = NO;
    }
    else {
        notificationSetting.active = YES;
    }
    
    [[LoadingView sharedInstance] show];
        
    [[WebApi sharedInstance]updateNotificationStatus:notificationSetting completion:^(NotificationSettings *set, NSError *err) {
        [[LoadingView sharedInstance] hide];
    }];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
