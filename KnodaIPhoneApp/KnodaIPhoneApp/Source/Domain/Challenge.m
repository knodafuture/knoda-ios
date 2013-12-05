//
//  NewChallenge.m
//  KnodaIPhoneApp
//
//  Created by nick on 12/6/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "Challenge.h"

@implementation Challenge

+ (id)instanceFromDictionary:(NSDictionary *)dictionary {
    Challenge *challenge = [super instanceFromDictionary:dictionary];
    
    if (!challenge)
        return nil;
    
    challenge.challengeId = [dictionary[@"id"] integerValue];
    challenge.seen = [dictionary[@"seen"] boolValue];
    challenge.agree = [dictionary[@"agree"] boolValue];
    challenge.isOwn = [dictionary[@"is_own"] boolValue];
    challenge.isRight = [dictionary[@"is_right"] boolValue];
    challenge.isFinished = [dictionary[@"is_finished"] boolValue];
    challenge.isBS = [dictionary[@"bs"] boolValue];
    
    
    return challenge;
}

@end
