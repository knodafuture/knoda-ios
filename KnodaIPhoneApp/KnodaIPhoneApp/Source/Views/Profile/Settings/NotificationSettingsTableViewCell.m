//
//  settingsTableCell.m
//  KnodaIPhoneApp
//
//  Created by Grant Isom on 6/17/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "NotificationSettingsTableViewCell.h"

static UINib *nib;

@implementation NotificationSettingsTableViewCell

+ (void)initialize {
    nib = [UINib nibWithNibName:@"NotificationSettingsTableViewCell" bundle:[NSBundle mainBundle]];
}

+ (NotificationSettingsTableViewCell *)cellForTableView:(UITableView *)tableView {
    NotificationSettingsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell)
        cell = [[nib instantiateWithOwner:nil options:nil] firstObject];
    
    cell.switchIndicator.onTintColor = [UIColor colorFromHex:@"235C37"];
    cell.switchIndicator.tintColor = [UIColor colorFromHex:@"efefef"];
    return cell;
}




- (IBAction)switchChanged:(id)sender {
    if ([self.delegate respondsToSelector:@selector(settingsChanged:inCell:)]) {
        [Flurry logEvent: @"Swiped_Agree"];
        [self.delegate settingsChanged:self.notificationSettings inCell:self];
    }
}
@end
