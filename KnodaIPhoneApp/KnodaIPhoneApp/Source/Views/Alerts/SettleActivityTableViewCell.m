//
//  SettleActivityTableViewCell.m
//  KnodaIPhoneApp
//
//  Created by nick on 7/2/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "SettleActivityTableViewCell.h"
#import "ActivityItem.h"

static UINib *nib;
static SettleActivityTableViewCell *defaultCell;
static NSMutableDictionary *cellheights;

@implementation SettleActivityTableViewCell

+ (void)initialize {
    nib = [UINib nibWithNibName:@"SettleActivityTableViewCell" bundle:[NSBundle mainBundle]];
    defaultCell = [[nib instantiateWithOwner:nil options:nil] lastObject];
    cellheights = [NSMutableDictionary dictionary];
}

+ (SettleActivityTableViewCell *)cellForTableView:(UITableView *)tableView {
    SettleActivityTableViewCell *cell;// = [tableView dequeueReusableCellWithIdentifier:@"SettleActivity"];
    
    if (!cell)
        cell = [[nib instantiateWithOwner:nil options:nil] lastObject];
    
    return cell;
}

- (void)populate:(ActivityItem *)item {
    
    self.titleLabel.textColor = [UIColor colorFromHex:@"235C37"];
    
    self.titleLabel.text = item.title;
    
    CGRect frame = self.titleLabel.frame;
    
    CGSize size = [self.titleLabel.text sizeWithFont:self.titleLabel.font
                                   constrainedToSize:CGSizeMake(self.titleLabel.frame.size.width, MAXFLOAT)
                                       lineBreakMode:NSLineBreakByWordWrapping];
    frame.size.height = size.height;
    self.titleLabel.frame = frame;
    
    self.bodyLabel.text = [NSString stringWithFormat:@"\"%@\"", item.body];
    
    size = [self.bodyLabel.text sizeWithFont:self.bodyLabel.font
                         constrainedToSize:CGSizeMake(self.bodyLabel.frame.size.width, MAXFLOAT)
                             lineBreakMode:NSLineBreakByWordWrapping];
    frame = self.bodyLabel.frame;
    frame.size.height = size.height;
    CGFloat padding = self.titleLabel.frame.origin.y;
    frame.origin.y = self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + padding / 2;
    
    self.bodyLabel.frame = frame;
    
    frame = self.settleButton.frame;
    
    frame.origin.y = self.bodyLabel.frame.origin.y + self.bodyLabel.frame.size.height + padding;
    
    self.settleButton.frame = frame;
    
    if (item.seen) {
        self.dotImageView.hidden = YES;
    } else {
        frame = self.dotImageView.frame;
        frame.origin.x = self.avatarImageView.frame.origin.x + self.avatarImageView.frame.size.width - frame.size.width;
        frame.origin.y = self.avatarImageView.frame.origin.y + self.avatarImageView.frame.size.height - frame.size.height;
        self.dotImageView.frame = frame;
    }
}

+ (CGFloat)heightForActivityItem:(ActivityItem *)item {
    
    CGFloat height = [cellheights[@(item.activityItemId)] floatValue];
    
    if (height)
        return height;
    
    defaultCell.titleLabel.text = item.title;
    CGSize titleSize = [defaultCell.titleLabel sizeThatFits:CGSizeMake(defaultCell.titleLabel.frame.size.width, CGFLOAT_MAX)];
    
    defaultCell.bodyLabel.text = [NSString stringWithFormat:@"\"%@\"", item.body];
    CGSize bodySize = [defaultCell.bodyLabel sizeThatFits:CGSizeMake(defaultCell.bodyLabel.frame.size.width, CGFLOAT_MAX)];
    
    CGFloat padding =  defaultCell.titleLabel.frame.origin.y;
    
    CGFloat buttonHeight = defaultCell.settleButton.frame.size.height;
    
    height = padding + titleSize.height + padding + bodySize.height + padding + buttonHeight + padding;
    
    cellheights[@(item.activityItemId)] = @(height);
    
    return height;
}
@end
