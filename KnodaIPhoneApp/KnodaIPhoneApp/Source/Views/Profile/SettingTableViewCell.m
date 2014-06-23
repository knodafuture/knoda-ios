//
//  settingsTableCell.m
//  KnodaIPhoneApp
//
//  Created by Grant Isom on 6/17/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "SettingTableViewCell.h"

static UINib *nib;

@implementation SettingTableViewCell

+ (void)initialize {
    nib = [UINib nibWithNibName:@"SettingsTableViewCell" bundle:[NSBundle mainBundle]];
}

+ (SettingTableViewCell *)cellForTableView:(UITableView *)tableView {
    SettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell)
        cell = [[nib instantiateWithOwner:nil options:nil] firstObject];
    
    cell.switchIndicator.onTintColor = [UIColor colorFromHex:@"2BA9E1"];
    cell.switchIndicator.tintColor = [UIColor colorFromHex:@"efefef"];
    cell.descriptionView.font = [UIFont fontWithName:@"HelveticaNeue" size:10.0];
    return cell;
}




- (IBAction)switchChanged:(id)sender {
    if ([self.delegate respondsToSelector:@selector(settingsChanged:inCell:)]) {
        [Flurry logEvent: @"Swiped_Agree"];
        [self.delegate settingsChanged:self.notificationSettings inCell:self];
    }
}
@end
