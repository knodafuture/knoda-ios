//
//  settingsTableCell.h
//  KnodaIPhoneApp
//
//  Created by Grant Isom on 6/17/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface settingsTableCell : UITableViewCell

+ (settingsTableCell *)cellForTableView:(UITableView *)tableView;

@property (weak, nonatomic) IBOutlet UISwitch *switchIndicator;

@property (weak, nonatomic) IBOutlet UILabel *displayName;
@property (weak, nonatomic) IBOutlet UITextView *descriptionView;

@end
