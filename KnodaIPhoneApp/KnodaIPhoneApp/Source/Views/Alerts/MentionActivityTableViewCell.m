//
//  MentionActivityTableViewCell.m
//  KnodaIPhoneApp
//
//  Created by nick on 10/12/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "MentionActivityTableViewCell.h"
#import "ActivityItem+Utils.h"

static UINib *nib;
static MentionActivityTableViewCell *defaultCell;
static NSMutableDictionary *cellHeights;

@implementation MentionActivityTableViewCell

+ (void)initialize {
    nib = [UINib nibWithNibName:@"MentionTableViewCell" bundle:[NSBundle mainBundle]];
    defaultCell = [[nib instantiateWithOwner:nil options:nil] lastObject];
    cellHeights = [NSMutableDictionary dictionary];
}

+ (MentionActivityTableViewCell *)cellForTableView:(UITableView *)tableView {
    MentionActivityTableViewCell *cell;// = [tableView dequeueReusableCellWithIdentifier:@"CommentActivityCell"];
    
    if (!cell) {
        cell = [[nib instantiateWithOwner:nil options:nil] lastObject];
        
        cell.avatarImageView.layer.cornerRadius = cell.avatarImageView.frame.size.width / 2.0;
        cell.avatarImageView.clipsToBounds = YES;
    }
    
    return cell;
}

+ (CGFloat)heightForActivityItem:(ActivityItem *)activityItem {
    
    CGFloat height = [cellHeights[@(activityItem.activityItemId)] floatValue];
    
    if (height)
        return height;
    
    defaultCell.titleLabel.text = activityItem.title;
    CGSize titleSize = [defaultCell.titleLabel sizeThatFits:CGSizeMake(defaultCell.titleLabel.frame.size.width, CGFLOAT_MAX)];
    
    defaultCell.bodyLabel.text = [NSString stringWithFormat:@"\"%@\"",activityItem.body];
    CGSize bodySize = [defaultCell.bodyLabel sizeThatFits:CGSizeMake(defaultCell.bodyLabel.frame.size.width, CGFLOAT_MAX)];
    
    CGFloat padding =  defaultCell.titleLabel.frame.origin.y;
    
    defaultCell.createdLabel.text = [activityItem creationString];
    CGSize creationSize = [defaultCell.createdLabel sizeThatFits:CGSizeMake(defaultCell.createdLabel.frame.size.width, CGFLOAT_MAX)];
    
    
    height = padding + titleSize.height + padding + bodySize.height + padding * 4 + creationSize.height;
    
    cellHeights[@(activityItem.activityItemId)] = @(height);
    
    return height;
}

- (void)populate:(ActivityItem *)activityItem {
    
    self.titleLabel.text = activityItem.title;
    
    CGRect frame = self.titleLabel.frame;
    
    CGSize size = [self.titleLabel.text sizeWithFont:self.titleLabel.font
                                   constrainedToSize:CGSizeMake(self.titleLabel.frame.size.width, MAXFLOAT)
                                       lineBreakMode:NSLineBreakByWordWrapping];
    frame.size.height = size.height;
    self.titleLabel.frame = frame;
    
    CGSize titleSize = size;
    self.bodyLabel.text = [NSString stringWithFormat:@"\"%@\"",activityItem.body];
    size = [self.bodyLabel.text sizeWithFont:self.bodyLabel.font
                           constrainedToSize:CGSizeMake(self.bodyLabel.frame.size.width, MAXFLOAT)
                               lineBreakMode:NSLineBreakByWordWrapping];
    
    frame = self.bodyLabel.frame;
    
    frame.origin.y = self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + self.titleLabel.frame.origin.y * 2;
    
    if (titleSize.height < 27.0)
        frame.origin.y += 2;
    
    frame.size.height = size.height;
    self.bodyLabel.frame = frame;
    self.titleLabel.textColor = [UIColor colorFromHex:@"235C37"];
    self.createdLabel.text = [activityItem creationString];
    [self.createdLabel sizeToFit];
    
    self.bubbleImageView.image = [[UIImage imageNamed:@"NotificationCommentBg"] resizableImageWithCapInsets:UIEdgeInsetsMake(9, 7, 4, 7)];
    
    frame = self.bubbleImageView.frame;
    
    frame.size.height = self.bodyLabel.frame.size.height + self.titleLabel.frame.origin.y * 2;
    frame.origin.y = self.bodyLabel.frame.origin.y - self.titleLabel.frame.origin.y;
    frame.origin.x = self.bodyLabel.frame.origin.x - 7.0 - self.titleLabel.frame.origin.y;
    frame.size.width = self.frame.size.width - frame.origin.x - self.titleLabel.frame.origin.y * 2 + 7;
    
    self.bubbleImageView.frame = frame;
    
    if (activityItem.seen) {
        self.dotImageView.hidden = YES;
    } else {
        CGRect frame = self.dotImageView.frame;
        frame.origin.x = self.avatarImageView.frame.origin.x + self.avatarImageView.frame.size.width - frame.size.width;
        frame.origin.y = self.avatarImageView.frame.origin.y + self.avatarImageView.frame.size.height - frame.size.height;
        self.dotImageView.frame = frame;
    }
}

@end