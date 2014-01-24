//
//  Comment.m
//  KnodaIPhoneApp
//
//  Created by Nick R on 11/17/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "Comment.h"
#import "Challenge.h"

@implementation Comment

+ (NSString *)responseKey {
    return @"comments";
}

+ (id)instanceFromDictionary:(NSDictionary *)dictionary {
    Comment *comment = [super instanceFromDictionary:dictionary];
    
    comment.commentId = [dictionary[@"id"] intValue];
    comment.userId = [dictionary[@"user_id"] intValue];
    comment.predictionId = [dictionary[@"prediction_id"] intValue];
    comment.body = dictionary[@"text"];
    if ([comment.body isKindOfClass:NSNull.class])
        comment.body = @"";
    comment.createdDate = [comment dateFromObject:dictionary[@"created_at"]];
    comment.challenge = [Challenge instanceFromDictionary:dictionary[@"challenge"]];
    comment.username = dictionary[@"username"];
    comment.verifiedAccount = [dictionary[@"verified_account"] boolValue];
    NSDictionary *imageDictionary = dictionary[@"user_avatar"];
    
    if ([imageDictionary isKindOfClass:[NSDictionary class]]) {
        comment.thumbUserImage = imageDictionary[@"thumb"];
        comment.smallUserImage = imageDictionary[@"small"];
        comment.bigUserImage   = imageDictionary[@"big"];
    }
    
    return comment;
    
}

@end
