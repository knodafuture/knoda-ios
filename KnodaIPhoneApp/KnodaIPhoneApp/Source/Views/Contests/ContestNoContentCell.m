//
//  ContestNoContentCell.m
//  KnodaIPhoneApp
//
//  Created by nick on 8/12/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "ContestNoContentCell.h"

static UINib *nib;

@implementation ContestNoContentCell

+ (void)initialize {
    nib = [UINib nibWithNibName:@"ContestNoContentCell" bundle:[NSBundle mainBundle]];
}

+ (ContestNoContentCell *)cellWithMessage:(NSString *)message {
    
    ContestNoContentCell *cell = [[nib instantiateWithOwner:nil options:nil] lastObject];
    
    cell.messageLabel.text = message;
    [cell.messageLabel sizeToFit];
    
    CGRect frame = cell.messageLabel.frame;
    frame.size.width = cell.frame.size.width - 10.0;
    cell.messageLabel.frame = frame;
    return cell;
}

@end
