//
//  AutocompleteHashtagTableViewCell.h
//  KnodaIPhoneApp
//
//  Created by nick on 10/11/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AutocompleteHashtagTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

+ (AutocompleteHashtagTableViewCell *)cellForTableView:(UITableView *)tableView;
@end
