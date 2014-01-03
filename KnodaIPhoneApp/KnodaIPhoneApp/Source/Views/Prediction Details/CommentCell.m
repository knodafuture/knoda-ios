//
//  CommentCell.m
//  KnodaIPhoneApp
//
//  Created by Nick R on 11/17/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "CommentCell.h"
#import "Comment+Utils.h"
#import "Challenge.h"

static UINib *nib;
static UIFont *defaultBodyLabelFont;
static CGFloat defaultHeight;
static UILabel *defaultBodyLabel;
static NSMutableDictionary *cellHeights;


@implementation CommentCell


+ (void)initialize {
    
    nib = [UINib nibWithNibName:@"CommentCell" bundle:[NSBundle mainBundle]];
    
    CommentCell *tmp = [[nib instantiateWithOwner:nil options:nil] lastObject];
    
    defaultBodyLabelFont = tmp.bodyLabel.font;
    defaultHeight = tmp.frame.size.height;
    defaultBodyLabel = tmp.bodyLabel;
    cellHeights = [[NSMutableDictionary alloc] init];
}

+ (CommentCell *)commentCellForTableView:(UITableView *)tableView {
    
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell"];
    
    if (!cell)
        cell = [[nib instantiateWithOwner:nil options:nil] lastObject];
    
    return cell;
}

+ (CGFloat)heightForComment:(Comment *)comment {
    
    CGFloat height = [[cellHeights objectForKey:@(comment.commentId)] floatValue];
    
    if (height)
        return height;
    
    defaultBodyLabel.text = comment.body;

    CGSize textSize = [defaultBodyLabel sizeThatFits:CGSizeMake(defaultBodyLabel.frame.size.width, CGFLOAT_MAX)];

    if (textSize.height < defaultBodyLabel.frame.size.height)
        height = defaultHeight;
    else
        height = defaultHeight + (textSize.height - defaultBodyLabel.frame.size.height);
    
    [cellHeights setObject:@(height) forKey:@(comment.commentId)];
    
    return height;
}


- (void)fillWithComment:(Comment *)comment {
    self.comment = comment;
    
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

- (IBAction)profileClicked:(id)sender {
    [self.delegate userClickedInCommentCellWithUserId:self.comment.userId];
}
@end
