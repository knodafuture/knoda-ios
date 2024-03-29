//
//  settingsTableCell.h
//  KnodaIPhoneApp
//
//  Created by Grant Isom on 6/17/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NotificationSettings;
@class NotificationSettingsTableViewCell;
@protocol SettingsDelegate <NSObject>
- (void)settingsChanged:(NotificationSettings *)notificationSetting inCell:(NotificationSettingsTableViewCell *)cell;
@end

@interface NotificationSettingsTableViewCell : UITableViewCell

+ (NotificationSettingsTableViewCell *)cellForTableView:(UITableView *)tableView;

@property (weak, nonatomic) IBOutlet UISwitch *switchIndicator;
@property (weak, nonatomic) id<SettingsDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *displayName;
@property (weak, nonatomic) IBOutlet UILabel *descriptionView;
@property (weak, nonatomic) NotificationSettings *notificationSettings;
@property (assign, nonatomic) BOOL changed;
- (IBAction)switchChanged:(id)sender;

@end
