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
static NSDictionary *linkAttributes;

static inline NSRegularExpression * MentionRegularExpression() {
    static NSRegularExpression *_mentionRegularExpression = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _mentionRegularExpression = [[NSRegularExpression alloc] initWithPattern:@"((?:^|\\s)(?:@){1}[0-9a-zA-Z_]{1,15})" options:NSRegularExpressionCaseInsensitive error:nil];
    });
    
    return _mentionRegularExpression;
}

static inline NSRegularExpression * HashtagRegularExpression() {
    static NSRegularExpression *_hashtagRegularExpression = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _hashtagRegularExpression = [[NSRegularExpression alloc] initWithPattern:@"((?:#){1}[\\w\\d]{1,140})" options:NSRegularExpressionCaseInsensitive error:nil];
    });
    
    return _hashtagRegularExpression;
}


@interface CommentCell () <TTTAttributedLabelDelegate>

@end

@implementation CommentCell


+ (void)initialize {
    
    nib = [UINib nibWithNibName:@"CommentCell" bundle:[NSBundle mainBundle]];
    
    CommentCell *tmp = [[nib instantiateWithOwner:nil options:nil] lastObject];
    
    defaultBodyLabelFont = tmp.bodyLabel.font;
    defaultHeight = tmp.frame.size.height;
    defaultBodyLabel = tmp.bodyLabel;
    cellHeights = [[NSMutableDictionary alloc] init];
    
    NSArray *keys = [[NSArray alloc] initWithObjects:(id)kCTForegroundColorAttributeName,(id)kCTUnderlineStyleAttributeName, (__bridge NSString *)kCTFontAttributeName, nil];
    NSArray *objects = [[NSArray alloc] initWithObjects:[UIColor colorFromHex:@"77BC1F"],[NSNumber numberWithInt:kCTUnderlineStyleNone], [UIFont fontWithName:@"HelveticaNeue-Medium" size:15.0], nil];
    linkAttributes = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];

}

+ (CommentCell *)commentCellForTableView:(UITableView *)tableView {
    
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell"];
    
    if (!cell) {
        cell = [[nib instantiateWithOwner:nil options:nil] lastObject];
        cell.bodyLabel.delegate = cell;
        cell.bodyLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
        cell.bodyLabel.activeLinkAttributes = nil;
    }
    
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


- (void)setBody:(NSString *)text {
    self.bodyLabel.text = text;
    
    NSRegularExpression *mentionExpression = MentionRegularExpression();
    
    NSArray *matches = [mentionExpression matchesInString:text
                                                  options:0
                                                    range:NSMakeRange(0, [text length])];
    for (NSTextCheckingResult *match in matches) {
        [self.bodyLabel addLinkWithTextCheckingResult:match attributes:linkAttributes];
    }
    
    NSRegularExpression *hashTagExpression = HashtagRegularExpression() ;
    matches = [hashTagExpression matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    
    for (NSTextCheckingResult *match in matches) {
        [self.bodyLabel addLinkWithTextCheckingResult:match attributes:linkAttributes];
    }
}

- (void)fillWithComment:(Comment *)comment {
    self.comment = comment;
    
    self.usernameLabel.text = comment.username;
    self.metaDataLabel.text = [comment createdAtString];
    [self setBody:comment.body];
    
    if (comment.challenge)
        self.voteImage.image = [UIImage imageNamed:comment.challenge.agree ? @"AgreeMarker" : @"DisagreeMarker"];
    else
        self.voteImage.image = nil;
    
    CGRect frame = self.frame;
    
    frame.size.height = [CommentCell heightForComment:comment];
    
    self.frame = frame;
    
    if (!self.comment.verifiedAccount) {
        self.verifiedCheckmark.hidden = YES;
    } else {
        self.verifiedCheckmark.hidden = NO;
        CGSize textSize = [self.usernameLabel sizeThatFits:self.usernameLabel.frame.size];
        
        CGRect frame = self.verifiedCheckmark.frame;
        frame.origin.x = self.usernameLabel.frame.origin.x + textSize.width + 5.0;
        self.verifiedCheckmark.frame = frame;
    }

}

- (IBAction)profileClicked:(id)sender {
    [self.delegate userClickedInCommentCellWithUserId:self.comment.userId];
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithTextCheckingResult:(NSTextCheckingResult *)result  {
    NSString *selectedText = [self.comment.body substringWithRange:result.range];
    NSString *stripped = [selectedText stringByReplacingOccurrencesOfString:@"@" withString:@""];
    stripped = [stripped stringByReplacingOccurrencesOfString:@"#" withString:@""];
    if ([selectedText rangeOfString:@"@"].location != NSNotFound) {
        [self.delegate userMentionSelected:stripped];
    } else if ([selectedText rangeOfString:@"#"].location != NSNotFound) {
        [self.delegate hashtagSelected:stripped];
    }
}
@end
