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
#import "UserManager.h"
#import "AutoCompleteTableViewController.h"
#import "TextViewWatcher.h" 

static NSString *const defaultCommentText = @"Add a comment...";
static const NSInteger CommentMaxChars = 300;

@interface CreateCommentView () <UITextViewDelegate, TextViewWatcherDelegate, AutoCompleteTableViewControllerDelegate>
@property (assign, nonatomic) CGFloat initialOrigin;
@property (assign, nonatomic) NSInteger predictionId;
@property (strong, nonatomic) TextViewWatcher *textViewWatcher;
@property (strong, nonatomic) AutoCompleteTableViewController *autoCompleteController;
@end

@implementation CreateCommentView

+ (CreateCommentView *)createCommentViewForPrediction:(NSInteger)predictionId withDelegate:(id<CreateCommentViewDelegate>)delegate {
    UINib *nib = [UINib nibWithNibName:@"CreateCommentView" bundle:[NSBundle mainBundle]];
    CreateCommentView *view = [[nib instantiateWithOwner:nil options:nil] lastObject];
    view.delegate = delegate;
    view.predictionId = predictionId;
    [Flurry logEvent:@"CREATE_COMMENT"];
    view.textViewWatcher = [[TextViewWatcher alloc] initForTextView:view.commentTextView delegate:view];
    view.backgroundColor = [UIColor colorFromHex:@"efefef"];
    [view.textViewWatcher observePrefix:@"@"];
    [view.textViewWatcher observePrefix:@"#"];

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
    
    if (!self.autoCompleteController) {
        self.autoCompleteController = [[AutoCompleteTableViewController alloc] initWithDelegate:self];
        
        CGRect frame = self.autoCompleteController.view.frame;
        frame.size.height = self.frame.size.height - (self.commentTextView.frame.origin.y + self.commentTextView.frame.size.height);
        frame.origin.y = self.frame.size.height;
        self.autoCompleteController.view.frame = frame;
        
        [self addSubview:self.autoCompleteController.view];
        [self bringSubviewToFront:self.autoCompleteController.view];
    }
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
    self.textCounterLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)(CommentMaxChars - textView.text.length)];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    NSInteger len = textView.text.length - range.length + text.length;
    
    if ([text isEqualToString:@"\n"]) {
        [self submit];
        return NO;
    }
    
    if(len <= CommentMaxChars) {
        self.textCounterLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)(CommentMaxChars - len)];
        return YES;
    }
    
    
    return NO;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    if ([self.delegate respondsToSelector:@selector(createCommentViewDidBeginEditing:)])
        [self.delegate createCommentViewDidBeginEditing:self];
    
    textView.text = @"";
    
    self.textCounterLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)(CommentMaxChars - textView.text.length)];
    
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
    
    [[LoadingView sharedInstance] show];

    Comment *comment = [[Comment alloc] init];
    comment.body = self.commentTextView.text;
    comment.creationDate = [NSDate date];
    comment.predictionId = self.predictionId;
    comment.userId = [UserManager sharedInstance].user.userId;
    comment.userAvatar = [UserManager sharedInstance].user.avatar;
    comment.username = [UserManager sharedInstance].user.name;

    [[WebApi sharedInstance] createComment:comment completion:^(Comment *newComment, NSError *error) {
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

- (void)termSelected:(NSString *)term completionString:(NSString *)completionString withType:(AutoCompleteItemType)type inViewController:(AutoCompleteTableViewController *)viewController {
    
    if (type == AutoCompleteItemTypeHashtag) {
        completionString = [completionString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    }
    
    self.commentTextView.text = [self.commentTextView.text stringByReplacingCharactersInRange:NSMakeRange(self.textViewWatcher.currentPrefixLocation, term.length) withString:completionString];
    [self.textViewWatcher endObserving];
}

- (void)textViewWatcher:(TextViewWatcher *)textViewWatcher didEndObservingPrefix:(NSString *)prefix {
    
    CGRect frame = self.autoCompleteController.view.frame;
    frame.origin.y = self.frame.size.height;
    
    [UIView animateWithDuration:0.5 animations:^{
        self.autoCompleteController.view.frame = frame;
    }];
    
    [self refreshAutoCompleteResults:@"" prefix:@"#"];
}
- (void)textViewWatcher:(TextViewWatcher *)textViewWatcher didBeginObservingPrefix:(NSString *)prefix {
    
    CGRect frame = self.autoCompleteController.view.frame;
    
    frame.origin.y = self.commentTextView.frame.origin.y + self.commentTextView.frame.size.height + 5.0;
    
    [UIView animateWithDuration:0.5 animations:^{
        self.autoCompleteController.view.frame = frame;
    }];
    
    [self refreshAutoCompleteResults:@"" prefix:prefix];
}
- (void)prefix:(NSString *)prefix wasUpdatedInTextViewWatcher:(TextViewWatcher *)textViewWatcher newValue:(NSString *)newValue {
    
    [self refreshAutoCompleteResults:newValue prefix:prefix];
}


- (void)refreshAutoCompleteResults:(NSString *)term prefix:(NSString *)prefix {
    AutoCompleteItemType type = AutoCompleteItemTypeUnknown;
    
    if ([prefix isEqualToString:@"@"]) {
        type = AutoCompleteItemTypeMention;
    } else if ([prefix isEqualToString:@"#"]) {
        type = AutoCompleteItemTypeHashtag;
    }
    
    if (type != AutoCompleteItemTypeUnknown)
        [self.autoCompleteController loadSuggestionsForTerm:term type:type completion:^(NSArray *results) {
        }];
}
@end
