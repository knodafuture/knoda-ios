//
//  NotificationSettingsViewController.m
//  KnodaIPhoneApp
//
//  Created by Grant Isom on 6/18/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "NotificationSettingsViewController.h"
#import "settingsTableCell.h"
#import "WebApi.h"
#import "NotificationSettings.h"

@interface NotificationSettingsViewController () {
    Settings *settings;
    UIView *header;
    NotificationSettings *notificationSettings;
}

@end

@implementation NotificationSettingsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSInteger)numberOfSections {
    
    return [settings settings].count;

}

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (void)viewDidLoad
{
    [[WebApi sharedInstance] getSettings:settings completion:^(Settings *settings, NSError *error) {
    }];
    NSLog(@"%@", settings.settings);
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem styledBarButtonItemWithTitle:@"Cancel" target:self action:@selector(cancel) color:[UIColor whiteColor]];
    self.title = @"SETTINGS";
    if (self.tableView.contentSize.height < self.tableView.frame.size.height) {
        self.tableView.scrollEnabled = NO;
    }
    else {
        self.tableView.scrollEnabled = YES;
    }
    
    //self.tableView. = [settings name];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    settingsTableCell *cell = [settingsTableCell cellForTableView:tableView];
    //if (indexPath.row >= self.pagingDatasource.objects.count)
        //return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    //NotificationSettings *setting = [self.pagingDatasource.objects objectAtIndex:indexPath.row];
    
    /*
    cell.displayName.text = [setting displayName];
    cell.descriptionView.text = [setting description];
    cell.switchIndicator.on = [setting active];
    cell.switchIndicator.tag = indexPath.row;
    */
    [cell.switchIndicator addTarget:self action:@selector(updateSwitch:) forControlEvents:UIControlEventValueChanged];
    
    return cell;
}

-(void)updateSwitch:(UISwitch *)sender {
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


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0)
        return 86.0;
    else {
        return 86.0;
    }
}

- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
