//
//  NotificationSettingsViewController.m
//  KnodaIPhoneApp
//
//  Created by Grant Isom on 6/18/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "NotificationSettingsViewController.h"
#import "SettingTableViewCell.h"
#import "WebApi.h"
#import "NotificationSettings.h"

@interface NotificationSettingsViewController ()

@property (strong, nonatomic) NSArray *settings;

@end

@implementation NotificationSettingsViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem styledBarButtonItemWithTitle:@"Cancel" target:self action:@selector(cancel) color:[UIColor whiteColor]];
    self.title = @"SETTINGS";
    if (self.tableView.contentSize.height < self.tableView.frame.size.height) {
        self.tableView.scrollEnabled = NO;
    }
    else {
        self.tableView.scrollEnabled = YES;
    }
    
    [self refresh];
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.settings[0] name];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger ret = [self.settings[section] settings].count;
    return ret;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SettingTableViewCell *cell = [SettingTableViewCell cellForTableView:tableView];
    
    Settings *settings = self.settings[indexPath.section];
    
    NotificationSettings *setting = settings.settings[indexPath.row];
    
    cell.displayName.text = [setting displayName];
    cell.descriptionView.text = [setting description];
    cell.switchIndicator.on = [setting active];
    cell.switchIndicator.tag = indexPath.row;
    [cell.switchIndicator addTarget:self action:@selector(updateSwitch:) forControlEvents:UIControlEventValueChanged];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0)
        return 86.0;
    else {
        return 86.0;
    }
}

- (void)updateSwitch:(UISwitch *)sender {
    NSLog(@"%ld", (long)sender.tag);
    NSInteger row = sender.tag;
   // NSArray *settings = self.pagingDatasource.objects;
    
   /* NotificationSettings *setting = settings[row];
    if (sender.isOn) {
        setting.active = YES;
    } else if (!sender.isOn) {
        setting.active = NO;
    }*/
    
    //[[WebApi sharedInstance] updateNotificationStatus:setting completion:^(NotificationSettings *settings, NSError *error) {}];
}




- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
