//
//  AutocompleteHashtagTableViewCell.m
//  KnodaIPhoneApp
//
//  Created by nick on 10/11/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "AutocompleteHashtagTableViewCell.h"

static UINib *nib;

@implementation AutocompleteHashtagTableViewCell

+ (void)initialize {
    nib = [UINib nibWithNibName:@"AutocompleteHastagTableViewCell" bundle:[NSBundle mainBundle]];
}

+ (AutocompleteHashtagTableViewCell *)cellForTableView:(UITableView *)tableView {
    AutocompleteHashtagTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HashtagCell"];
    
    if (!cell)
        cell = [[nib instantiateWithOwner:nil options:nil] lastObject];
    
    return cell;
}

@end
