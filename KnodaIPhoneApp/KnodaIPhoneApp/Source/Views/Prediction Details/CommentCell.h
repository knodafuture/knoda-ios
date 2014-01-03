//
//  CommentCell.h
//  KnodaIPhoneApp
//
//  Created by Nick R on 11/17/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Comment;

@protocol CommentCellDelegate <NSObject>

- (void)userClickedInCommentCellWithUserId:(NSInteger)userId;

@end

@interface CommentCell : UITableViewCell

@property (strong, nonatomic) Comment *comment;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *voteImage;
@property (weak, nonatomic) IBOutlet UILabel *bodyLabel;
@property (weak, nonatomic) IBOutlet UILabel *metaDataLabel;
@property (weak, nonatomic) id<CommentCellDelegate>delegate;

+ (CommentCell *)commentCellForTableView:(UITableView *)tableView;
+ (CGFloat)heightForComment:(Comment *)comment;

- (void)fillWithComment:(Comment *)comment;


@end
