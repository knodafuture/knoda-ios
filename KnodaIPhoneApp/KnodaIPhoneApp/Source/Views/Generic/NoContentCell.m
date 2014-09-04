//
//  NoContentCell.m
//  KnodaIPhoneApp
//
//  Created by Nick R on 11/22/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "NoContentCell.h"

static UINib *nib;

@implementation NoContentCell

+ (void)initialize {
    nib = [UINib nibWithNibName:@"NoContentCell" bundle:[NSBundle mainBundle]];
}

+ (NoContentCell *)noContentWithMessage:(NSString *)message forTableView:(UITableView *)tableView {
    
    NoContentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NoContentCell"];
    
    if (!cell)
        cell = [[nib instantiateWithOwner:nil options:nil] lastObject];
    
    cell.messageLabel.text = message;
    [cell.messageLabel sizeToFit];
    
    CGRect frame = cell.messageLabel.frame;
    frame.size.width = cell.frame.size.width - 10.0;
    cell.messageLabel.frame = frame;
    return cell;
}

+ (NoContentCell *)noContentWithMessage:(NSString *)message forTableView:(UITableView *)tableView height:(CGFloat)height {
    NoContentCell *cell = [NoContentCell noContentWithMessage:message forTableView:tableView];
    
    CGRect frame = cell.frame;
    frame.size.height = height;
    
    cell.frame = frame;
    
    return cell;
}

- (void)shiftDown:(CGFloat)points {
    CGRect frame = self.blahImageView.frame;
    frame.origin.y += points;
    self.blahImageView.frame = frame;
    
    frame = self.messageLabel.frame;
    frame.origin.y += points;
    self.messageLabel.frame = frame;
}

@end
