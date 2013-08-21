//
//  Prediction.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/9/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "Prediction.h"
#import "Chellange.h"
#import "NSDate+Utils.h"

static NSString* const kResponseDateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'zzz";

@implementation Prediction

- (id)initWithDictionary:(NSDictionary *)dictionary {
    if(self = [super init]) {
        self.ID = [[dictionary objectForKey: @"id"] integerValue];
        self.body = [dictionary objectForKey: @"body"];
        self.category = [[[dictionary objectForKey: @"tags"] objectAtIndex: 0] objectForKey: @"name"];
        self.agreeCount = [[dictionary objectForKey: @"agreed_count"] integerValue];
        self.disagreeCount = [[dictionary objectForKey: @"disagreed_count"] integerValue];
        self.voitedUsersCount = [[dictionary objectForKey: @"market_size"] integerValue];
        self.agreedPercent = [[dictionary objectForKey: @"prediction_market"] integerValue];
        self.expired = [[dictionary objectForKey: @"expired"] boolValue];
        self.settled = [[dictionary objectForKey: @"settled"] boolValue];
        self.userId = [[dictionary objectForKey: @"user_id"] integerValue];
        self.userName = [dictionary objectForKey: @"username"];
        
        if ([dictionary objectForKey: @"user_avatar"] != nil && ![[dictionary objectForKey: @"user_avatar"] isKindOfClass: [NSNull class]])
        {
            self.userAvatars = [dictionary objectForKey: @"user_avatar"];
        }
        
        if (![[dictionary objectForKey: @"outcome"] isKindOfClass: [NSNull class]])
        {
            self.outcome = [[dictionary objectForKey: @"outcome"] boolValue];
        }
        
        if ([dictionary objectForKey: @"created_at"] != nil && ![[dictionary objectForKey: @"created_at"] isKindOfClass: [NSNull class]])
        {
            self.creationDate = [NSDate dateFromString:[[dictionary objectForKey: @"created_at"] stringByAppendingString: @"GMT"] withFormat:kResponseDateFormat];
        }
        
        if ([dictionary objectForKey: @"expires_at"] != nil && ![[dictionary objectForKey: @"expires_at"] isKindOfClass: [NSNull class]])
        {
            self.expirationDate = [NSDate dateFromString:[[dictionary objectForKey: @"expires_at"] stringByAppendingString: @"GMT"] withFormat:kResponseDateFormat];
        }
        
        if ([dictionary objectForKey: @"my_challenge"] != nil && ![[dictionary objectForKey: @"my_challenge"] isKindOfClass: [NSNull class]])
        {
            NSDictionary* chellangeDictionary = [dictionary objectForKey: @"my_challenge"];
            self.chellange = [[Chellange alloc] initWithDictionary:chellangeDictionary];
            [self.chellange fillPoints:[dictionary objectForKey:@"my_points"]];
        }

    }
    return self;
}

- (NSString *)thumbAvatar {
    return self.userAvatars[@"thumb"];
}

- (NSString *)smallAvatar {
    return self.userAvatars[@"small"];
}

- (NSString *)bigAvatar {
    return self.userAvatars[@"big"];
}

- (void)setOutcome:(BOOL)outcome {
    _outcome = outcome;
    self.hasOutcome = YES;
}


- (NSString*) description
{
    
    NSString* result = [NSString stringWithFormat: @"\r\r***PREDICTION***\rid: %d\rcategory: %@\rbody: %@\rcreationDate: %@\rexpirationDate: %@\ragreeCount: %d\rdisagreeCount: %d\rvoitedUsersCount: %d\ragreePersent: %d\rexpired: %@\rhasOutcome: %@\routcome: %@\rsettled: %@\ruserId: %d\ruserName: %@\ruserAvatars: %@\rchellange: %@\r***", self.ID, self.category, self.body, self.creationDate, self.expirationDate, self.agreeCount, self.disagreeCount, self.voitedUsersCount, self.agreedPercent, (self.expired) ? @"YES" : @"NO", (self.hasOutcome) ? @"YES" : @"NO", (self.outcome) ? @"YES" : @"NO", (self.settled) ? @"YES" : @"NO", self.userId, self.userName, self.userAvatars, self.chellange];
    
    return result;
}


@end
