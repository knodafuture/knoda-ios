//
//  CreateCommentView.h
//  KnodaIPhoneApp
//
//  Created by nick on 12/7/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CreateCommentView;
@class Comment;
@protocol CreateCommentViewDelegate <NSObject>

- (void)createCommentViewDidBeginEditing:(CreateCommentView *)createCommentView;
- (void)createCommentViewDidCancel:(CreateCommentView *)createCommentView;
- (void)createCommentView:(CreateCommentView *)createCommentView didCreateComment:(Comment *)comment;


@end

@interface CreateCommentView : UIView

@property (weak, nonatomic) IBOutlet UITextView *commentTextView;
@property (weak, nonatomic) IBOutlet UILabel *textCounterLabel;
@property (weak, nonatomic) IBOutlet UIView *textViewContainer;

@property (weak, nonatomic) id<CreateCommentViewDelegate> delegate;

+ (CreateCommentView *)createCommentViewForPrediction:(NSInteger)predictionId withDelegate:(id<CreateCommentViewDelegate>)delegate;

- (CGFloat)heightForTeaser;

- (void)cancel;
- (void)submit;

@end
