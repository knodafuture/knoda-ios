//
//  CreateCommentWebRequest.m
//  KnodaIPhoneApp
//
//  Created by Nick R on 11/17/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "CreateCommentWebRequest.h"
#import "BadgesWebRequest.h"
#import "NSDate+Utils.h"
#import "Comment.h"

@interface CreateCommentWebRequest ()
@property (strong, nonatomic) Comment *comment;
@end

@implementation CreateCommentWebRequest

- (id)initWithComment:(Comment *)comment {
    NSDictionary *params = @{@"comment[text]": comment.body};
    self = [super initWithParameters:params];
    self.comment = comment;
    return self;
}


- (NSString*) methodName
{
    return [NSString stringWithFormat: @"predictions/%d/comment.json", self.comment.predictionId];
}


- (NSString*) httpMethod
{
    return @"POST";
}


- (BOOL) requiresAuthToken
{
    return YES;
}

- (NSString *)userFriendlyErrorDescription {
    return NSLocalizedString(@"Unable to post comment at this time.", @"");
}


- (void)executeWithCompletionBlock:(RequestCompletionBlock)completion {
    RequestCompletionBlock block = completion ? [completion copy] : nil;
    [super executeWithCompletionBlock:^{
        if(block) {
            block();
        }
        if(self.isSucceeded) {
            [BadgesWebRequest checkNewBadges];
        }
    }];
}
@end
