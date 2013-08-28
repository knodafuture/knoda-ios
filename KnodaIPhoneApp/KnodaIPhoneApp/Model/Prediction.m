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
        self.ID               = [[dictionary objectForKey: @"id"] integerValue];
        self.body             = [dictionary objectForKey: @"body"];
        self.agreeCount       = [[dictionary objectForKey: @"agreed_count"] integerValue];
        self.disagreeCount    = [[dictionary objectForKey: @"disagreed_count"] integerValue];
        self.voitedUsersCount = [[dictionary objectForKey: @"market_size"] integerValue];
        self.agreedPercent    = [[dictionary objectForKey: @"prediction_market"] integerValue];
        self.expired          = [[dictionary objectForKey: @"expired"] boolValue];
        self.settled          = [[dictionary objectForKey: @"settled"] boolValue];
        self.userId           = [[dictionary objectForKey: @"user_id"] integerValue];
        self.userName         = [dictionary objectForKey: @"username"];
        
        id obj = [dictionary objectForKey: @"tags"];
        if([obj isKindOfClass:[NSArray class]] && [obj count]) {
            self.category = [[obj objectAtIndex: 0] objectForKey: @"name"];
        }
        
        obj = [dictionary objectForKey: @"user_avatar"];
        if ([obj isKindOfClass:[NSDictionary class]]) {
            self.userAvatars = obj;
        }
        
        obj = [dictionary objectForKey: @"outcome"];
        if (obj && ![obj isKindOfClass: [NSNull class]])
        {
            self.outcome = [obj boolValue];
        }
        
        obj = [dictionary objectForKey: @"created_at"];
        if (obj && ![obj isKindOfClass: [NSNull class]])
        {
            self.creationDate = [NSDate dateFromString:[obj stringByAppendingString: @"GMT"] withFormat:kResponseDateFormat];
        }
        
        obj = [dictionary objectForKey: @"expires_at"];
        if (obj && ![obj isKindOfClass: [NSNull class]])
        {
            self.expirationDate = [NSDate dateFromString:[obj stringByAppendingString: @"GMT"] withFormat:kResponseDateFormat];
        }
    }
    return self;
}

- (void)setupChallenge:(NSDictionary *)challengeDict withPoints:(NSDictionary *)pointsDict {
    self.chellange = [[Chellange alloc] initWithDictionary:challengeDict];
    [self.chellange fillPoints:pointsDict];
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

- (BOOL)isExpired {
    return [self.expirationDate timeIntervalSinceNow] < 0;
}


- (NSString*) description
{
    
    NSString* result = [NSString stringWithFormat: @"\r\r***PREDICTION***\rid: %d\rcategory: %@\rbody: %@\rcreationDate: %@\rexpirationDate: %@\ragreeCount: %d\rdisagreeCount: %d\rvoitedUsersCount: %d\ragreePersent: %d\rexpired: %@\rhasOutcome: %@\routcome: %@\rsettled: %@\ruserId: %d\ruserName: %@\ruserAvatars: %@\rchellange: %@\r***", self.ID, self.category, self.body, self.creationDate, self.expirationDate, self.agreeCount, self.disagreeCount, self.voitedUsersCount, self.agreedPercent, (self.expired) ? @"YES" : @"NO", (self.hasOutcome) ? @"YES" : @"NO", (self.outcome) ? @"YES" : @"NO", (self.settled) ? @"YES" : @"NO", self.userId, self.userName, self.userAvatars, self.chellange];
    
    return result;
}


@end
