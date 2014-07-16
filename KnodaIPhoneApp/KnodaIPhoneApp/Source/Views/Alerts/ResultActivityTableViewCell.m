//
//  WinActivityTableViewCell.m
//  KnodaIPhoneApp
//
//  Created by nick on 6/22/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "ResultActivityTableViewCell.h"
#import "ActivityItem+Utils.h"

static UINib *nib;
static NSMutableDictionary *cellHeightCache;
static ResultActivityTableViewCell *defaultCell;


@implementation ResultActivityTableViewCell

+ (void)initialize {
    nib = [UINib nibWithNibName:@"ResultActivityTableViewCell" bundle:[NSBundle mainBundle]];
    cellHeightCache = [NSMutableDictionary dictionary];
    defaultCell = [[nib instantiateWithOwner:nil options:nil] firstObject];
}

+ (ResultActivityTableViewCell *)cellForTableView:(UITableView *)tableView delegate:(id<ResultActivityTableViewCellDelegate>)delegate {
 
    ResultActivityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WinActivity"];
    
    if (!cell) {
        cell = [[nib instantiateWithOwner:nil options:nil] lastObject];
        
        cell.avatarImageView.layer.cornerRadius = cell.avatarImageView.frame.size.width / 2.0;
        cell.avatarImageView.clipsToBounds = YES;
    }
    cell.delegate = delegate;
    return cell;
}

+ (CGFloat)heightForActivityItem:(ActivityItem *)activityItem {
    
    CGFloat height = [cellHeightCache[@(activityItem.activityItemId)] floatValue];
    
    if (height)
        return height;
    NSString *prefix = @"";
    
    if (activityItem.type == ActivityTypeWon) {
        prefix = @"You Won";
    } else {
        prefix = @"You Lost";
    }
    
    defaultCell.titleLabel.text = [NSString stringWithFormat:@"%@—%@", prefix, activityItem.title];
    CGSize titleSize = [defaultCell.titleLabel sizeThatFits:CGSizeMake(defaultCell.titleLabel.frame.size.width, CGFLOAT_MAX)];
    
    defaultCell.bodyLabel.text = [NSString stringWithFormat:@"\"%@\"", activityItem.body];
    CGSize bodySize = [defaultCell.bodyLabel sizeThatFits:CGSizeMake(defaultCell.bodyLabel.frame.size.width, CGFLOAT_MAX)];
    
    CGFloat padding =  defaultCell.titleLabel.frame.origin.y;
    
    CGFloat buttonHeight = defaultCell.bragButton.frame.size.height;
    
    height = padding + titleSize.height + padding + bodySize.height + padding;
    
    if (activityItem.type == ActivityTypeWon && activityItem.shareable)
        height = height + buttonHeight + padding;
    
    cellHeightCache[@(activityItem.activityItemId)] = @(height);
    
    return height;
}

- (void)populate:(ActivityItem *)activityItem {
    
    self.activityItem = activityItem;
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] init];
    
    NSString *prefix = @"";
    NSDictionary *titleAttributes = @{};
    
    if (activityItem.type == ActivityTypeWon) {
        prefix = @"You Won";
        titleAttributes = @{NSForegroundColorAttributeName: [UIColor colorFromHex:@"77BC1F"]};
    } else {
        prefix = @"You Lost";
        titleAttributes = @{NSForegroundColorAttributeName: [UIColor colorFromHex:@"FE3232"]};
    }

    
    if (activityItem.seen) {
        self.dotImageView.hidden = YES;
    } else {
        CGRect frame = self.dotImageView.frame;
        frame.origin.x = self.avatarImageView.frame.origin.x + self.avatarImageView.frame.size.width - frame.size.width;
        frame.origin.y = self.avatarImageView.frame.origin.y + self.avatarImageView.frame.size.height - frame.size.height;
        self.dotImageView.frame = frame;
    }
    
    [title appendAttributedString:[[NSAttributedString alloc] initWithString:prefix attributes:titleAttributes]];
    [title appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"—%@",activityItem.title] attributes:@{NSForegroundColorAttributeName : [UIColor colorFromHex:@"235C37"]}]];
    
    self.titleLabel.attributedText = title;
    CGRect frame = self.titleLabel.frame;
    
    CGSize size = [self.titleLabel.text sizeWithFont:self.titleLabel.font
                                  constrainedToSize:CGSizeMake(self.titleLabel.frame.size.width, MAXFLOAT)
                                      lineBreakMode:NSLineBreakByWordWrapping];
    frame.size.height = size.height;
    self.titleLabel.frame = frame;
    
    self.bodyLabel.text = [NSString stringWithFormat:@"\"%@\"", activityItem.body];
    
    size = [self.bodyLabel.text sizeWithFont:self.bodyLabel.font
                                  constrainedToSize:CGSizeMake(self.bodyLabel.frame.size.width, MAXFLOAT)
                                      lineBreakMode:NSLineBreakByWordWrapping];

    self.bragButton.hidden = ((activityItem.type != ActivityTypeWon) || (!activityItem.shareable));
    
    frame = self.bodyLabel.frame;
    CGFloat padding = self.titleLabel.frame.origin.y;
    
    frame.size.height = size.height;
    frame.origin.y = self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + padding / 2;
    
    self.bodyLabel.frame = frame;
    
    if ((activityItem.type != ActivityTypeWon))
        return;
    
    frame = self.bragButton.frame;
    
    frame.origin.y = self.bodyLabel.frame.origin.y + self.bodyLabel.frame.size.height + padding;
    
    self.bragButton.frame = frame;
}

- (IBAction)brag:(id)sender {
    if ([self.delegate respondsToSelector:@selector(resultActivityTableViewCell:didBragForActivityItem:)])
        [self.delegate resultActivityTableViewCell:self didBragForActivityItem:self.activityItem];
}

@end
