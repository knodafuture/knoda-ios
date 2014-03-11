//
//  CreateCommentView.m
//  KnodaIPhoneApp
//
//  Created by nick on 12/7/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "CreateCommentView.h"
#import "WebApi.h"
#import "LoadingView.h"
#import "AppDelegate.h"

static NSString *const defaultCommentText = @"Add a comment...";
static const int CommentMaxChars = 300;

@interface CreateCommentView () <UITextViewDelegate>
@property (assign, nonatomic) CGFloat initialOrigin;
@property (assign, nonatomic) NSInteger predictionId;
@end

@implementation CreateCommentView

+ (CreateCommentView *)createCommentViewForPrediction:(NSInteger)predictionId withDelegate:(id<CreateCommentViewDelegate>)delegate {
    UINib *nib = [UINib nibWithNibName:@"CreateCommentView" bundle:[NSBundle mainBundle]];
    CreateCommentView *view = [[nib instantiateWithOwner:nil options:nil] lastObject];
    view.delegate = delegate;
    view.predictionId = predictionId;
    
    return view;
}

- (CGFloat)heightForTeaser {
     CGSize textSize = [defaultCommentText sizeWithFont:self.commentTextView.font forWidth:self.commentTextView.frame.size.width lineBreakMode:NSLineBreakByTruncatingTail];
    return textSize.height;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (newSuperview) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willShowKeyBoard:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willHideKeyBoard:) name:UIKeyboardWillHideNotification object:nil];
    } else
        [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)willShowKeyBoard:(NSNotification *)object {
    
    NSTimeInterval animationDuration = [self keyboardAnimationDurationForNotification:object];
    
    CGRect frame = self.frame;
    self.initialOrigin = frame.origin.y;
    
    frame.origin.y = 0;
    
    [UIView animateWithDuration:animationDuration * 0.8 animations:^{
        self.frame = frame;
    }];
}

- (void)willHideKeyBoard:(NSNotification *)object {
    NSTimeInterval animationDuration = [self keyboardAnimationDurationForNotification:object];
    
    CGRect frame = self.frame;
    frame.origin.y = self.initialOrigin;
    
    [UIView animateWithDuration:animationDuration * 0.8 animations:^{
        self.frame = frame;
    }];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.textCounterLabel.text = [NSString stringWithFormat:@"%d", CommentMaxChars - textView.text.length];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    int len = textView.text.length - range.length + text.length;
    
    if ([text isEqualToString:@"\n"]) {
        [self submit];
        return NO;
    }
    
    if(len <= CommentMaxChars) {
        self.textCounterLabel.text = [NSString stringWithFormat:@"%d", CommentMaxChars - len];
        return YES;
    }
    
    return NO;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    if ([self.delegate respondsToSelector:@selector(createCommentViewDidBeginEditing:)])
        [self.delegate createCommentViewDidBeginEditing:self];
    
    textView.text = @"";
    
    self.textCounterLabel.text = [NSString stringWithFormat:@"%d", CommentMaxChars - textView.text.length];
    
}

- (NSTimeInterval)keyboardAnimationDurationForNotification:(NSNotification*)notification {
    NSDictionary* info = [notification userInfo];
    NSValue* value = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval duration = 0;
    [value getValue:&duration];
    return duration;
}

- (void)submit {
    
    if (self.commentTextView.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter a comment." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        return;
    }

    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [[LoadingView sharedInstance] show];

    Comment *comment = [[Comment alloc] init];
    comment.body = self.commentTextView.text;
    comment.creationDate = [NSDate date];
    comment.predictionId = self.predictionId;
    comment.userId = delegate.currentUser.userId;
    comment.userAvatar = delegate.currentUser.avatar;
    comment.username = delegate.currentUser.name;

    [[WebApi sharedInstance] createComment:comment completion:^(NSError *error) {
        [[LoadingView sharedInstance] hide];
        if (error) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Unable to post comment at this time." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        } else {
            [self cleanup];
            [self.delegate createCommentView:self didCreateComment:comment];
        }
    }];
    
}

- (void)cleanup {
    [self.commentTextView resignFirstResponder];
    self.commentTextView.text = defaultCommentText;

}

- (void)cancel {
    [self cleanup];
    [self.delegate createCommentViewDidCancel:self];
}

@end
