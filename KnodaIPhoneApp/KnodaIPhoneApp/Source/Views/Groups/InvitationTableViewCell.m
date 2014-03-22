//
//  InvitationTableViewCell.m
//  KnodaIPhoneApp
//
//  Created by nick on 3/19/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "InvitationTableViewCell.h"

static UINib *nib;

@interface InvitationTableViewCell ()
@property (weak, nonatomic) id<InvitationTableViewCellDelegate> delegate;
@property (strong, nonatomic) NSIndexPath *indexPath;

@end
@implementation InvitationTableViewCell

+ (void)initialize {
    nib = [UINib nibWithNibName:@"InvitationTableViewCell" bundle:[NSBundle mainBundle]];
}


+ (InvitationTableViewCell *)cellForTableView:(UITableView *)tableView onIndexPath:(NSIndexPath *)indexPath delegate:(id<InvitationTableViewCellDelegate>)delegate {
    
    InvitationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InvitationCell"];

    if (!cell) {
        cell = [[nib instantiateWithOwner:nil options:nil] firstObject];
        UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:cell action:@selector(hideConfirmRemove)];
        swipe.direction = UISwipeGestureRecognizerDirectionRight;
        [cell addGestureRecognizer:swipe];
    }
    cell.delegate = delegate;
    cell.indexPath = indexPath;
    return cell;
}

- (IBAction)remove:(id)sender {
    CGRect frame = self.removeConfirmButton.frame;
    frame.origin.x = self.frame.size.width - frame.size.width;
    [UIView animateWithDuration:.25 animations:^{
        self.removeConfirmButton.frame = frame;
    }];
}

- (IBAction)confirmRemove:(id)sender {
    [self hideConfirmRemove];
    [self.delegate InvitationTableViewCell:self didRemoveOnIndexPath:self.indexPath];
}

- (void)hideConfirmRemove {
    CGRect frame = self.removeConfirmButton.frame;
    frame.origin.x = self.frame.size.width;
    [UIView animateWithDuration:.25 animations:^{
        self.removeConfirmButton.frame = frame;
    }];
}


@end
