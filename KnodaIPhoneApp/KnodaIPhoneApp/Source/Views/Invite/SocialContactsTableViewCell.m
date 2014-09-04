//
//  SocialContactsTableViewCell.m
//  KnodaIPhoneApp
//
//  Created by nick on 8/25/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "SocialContactsTableViewCell.h"

static UINib *nib;

@implementation SocialContactsTableViewCell

+ (void)initialize {
    nib = [UINib nibWithNibName:@"SocialContactsTableViewCell" bundle:[NSBundle mainBundle]];
}

+ (SocialContactsTableViewCell *)cellForTableView:(UITableView *)tableView delegate:(id<SocialContactsTableViewCellDelegate>)delegate indexPath:(NSIndexPath *)indexPath {
    SocialContactsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SocialContactCell"];
    
    if (!cell) {
        cell = [[nib instantiateWithOwner:nil options:nil] lastObject];
    }
    
    cell.delegate = delegate;
    cell.indexPath = indexPath;
    
    return cell;
}

- (IBAction)toggleSelected:(id)sender {
    self.contactSelected = !self.contactSelected;
    
    if (self.contactSelected)
        [self.delegate contactSelectedInCell:self atIndexPath:self.indexPath];
    else
        [self.delegate contactUnselectedInCell:self atIndexPath:self.indexPath];
}

- (void)setContactSelected:(BOOL)contactSelected {
    _contactSelected = contactSelected;
    
    if (contactSelected)
        [self.inviteButton setImage:[UIImage imageNamed:@"InviteIconActive"] forState:UIControlStateNormal];
    else
        [self.inviteButton setImage:[UIImage imageNamed:@"InviteAddIcon"] forState:UIControlStateNormal];
}
@end
