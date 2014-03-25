//
//  MemberTableViewCell.m
//  KnodaIPhoneApp
//
//  Created by nick on 3/19/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "MemberTableViewCell.h"


static UINib *nib;
@interface MemberTableViewCell ()
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (weak, nonatomic) id<MemberTableViewCellDelegate> delegate;
@end

@implementation MemberTableViewCell

+ (void)initialize {
    nib = [UINib nibWithNibName:@"MemberTableViewCell" bundle:[NSBundle mainBundle]];
}

+ (MemberTableViewCell *)cellForTableView:(UITableView *)tableView delegate:(id<MemberTableViewCellDelegate>)delegate indexPath:(NSIndexPath *)indexPath {
    MemberTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"memberCell"];
    
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
    [self.delegate MemberTableViewCell:self didRemoveOnIndexPath:self.indexPath];
}

- (void)hideConfirmRemove {
    CGRect frame = self.removeConfirmButton.frame;
    frame.origin.x = self.frame.size.width;
    [UIView animateWithDuration:.25 animations:^{
        self.removeConfirmButton.frame = frame;
    }];
}

@end
