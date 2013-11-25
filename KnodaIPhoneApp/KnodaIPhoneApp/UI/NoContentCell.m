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
    
    return cell;
}

+ (NoContentCell *)noContentWithMessage:(NSString *)message forTableView:(UITableView *)tableView height:(CGFloat)height {
    NoContentCell *cell = [NoContentCell noContentWithMessage:message forTableView:tableView];
    
    CGRect frame = cell.frame;
    frame.size.height = height;
    
    cell.frame = frame;
    
    return cell;
}

@end