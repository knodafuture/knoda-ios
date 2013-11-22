//
//  CommentCell.m
//  KnodaIPhoneApp
//
//  Created by Nick R on 11/17/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "CommentCell.h"
#import "Comment.h"
#import "BindableView.h"
#import "Challenge.h"

static UINib *nib;
static UIFont *defaultBodyLabelFont;
static CGFloat defaultHeight;
static UILabel *defaultBodyLabel;

@implementation CommentCell


+ (void)initialize {
    
    nib = [UINib nibWithNibName:@"CommentCell" bundle:[NSBundle mainBundle]];
    
    CommentCell *tmp = [[nib instantiateWithOwner:nil options:nil] lastObject];
    
    defaultBodyLabelFont = tmp.bodyLabel.font;
    defaultHeight = tmp.frame.size.height;
    defaultBodyLabel = tmp.bodyLabel;

}

+ (CommentCell *)commentCellForTableView:(UITableView *)tableView {
    
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell"];
    
    if (!cell)
        cell = [[nib instantiateWithOwner:nil options:nil] lastObject];
    
    return cell;
}

+ (CGFloat)heightForComment:(Comment *)comment {
    defaultBodyLabel.text = comment.body;

    CGSize textSize = [defaultBodyLabel sizeThatFits:CGSizeMake(defaultBodyLabel.frame.size.width, CGFLOAT_MAX)];

    if (textSize.height < defaultBodyLabel.frame.size.height)
        return defaultHeight;
    else
        return defaultHeight + (textSize.height - defaultBodyLabel.frame.size.height);
}


- (void)fillWithComment:(Comment *)comment {
    
    [self.avatarView bindToURL:comment.smallUserImage];
    
    self.usernameLabel.text = comment.username;
    self.bodyLabel.text = comment.body;
    self.metaDataLabel.text = [comment createdAtString];
    
    if (comment.challenge)
        self.voteImage.image = [UIImage imageNamed:comment.challenge.agree ? @"AgreeMarker" : @"DisagreeMarker"];
    else
        self.voteImage.image = nil;
    
    CGRect frame = self.frame;
    
    frame.size.height = [CommentCell heightForComment:comment];
    
    self.frame = frame;

}

@end
