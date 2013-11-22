//
//  Prediction.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/9/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "Prediction.h"
#import "Challenge.h"
#import "NSDate+Utils.h"


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
        self.isReadyForResolution = [[dictionary objectForKey:@"is_ready_for_resolution"] boolValue];
        self.settled          = [[dictionary objectForKey: @"settled"] boolValue];
        self.userId           = [[dictionary objectForKey: @"user_id"] integerValue];
        self.userName         = [dictionary objectForKey: @"username"];
        self.commentCount     = [[dictionary objectForKey:@"comment_count"] integerValue];
        self.shortUrl         = [dictionary objectForKey:@"short_url"];
        
        
        id obj = [dictionary objectForKey: @"tags"];
        if([obj isKindOfClass:[NSArray class]] && [obj count]) {
            self.category = [[obj objectAtIndex: 0] objectForKey: @"name"];
        }
        
        obj = [dictionary objectForKey: @"user_avatar"];
        if ([obj isKindOfClass:[NSDictionary class]]) {
            self.thumbAvatar = obj[@"thumb"];
            self.smallAvatar = obj[@"small"];
            self.bigAvatar   = obj[@"big"];
        }
        
        obj = [dictionary objectForKey: @"outcome"];
        if (obj && ![obj isKindOfClass: [NSNull class]])
        {
            self.outcome = [obj boolValue];
        }
        
        self.creationDate   = [self dateFromObject:dictionary[@"created_at"]];
        self.expirationDate = [self dateFromObject:dictionary[@"expires_at"]];
        self.resolutionDate = [self dateFromObject:dictionary[@"resolution_date"]];
    }
    return self;
}

- (void)setupChallenge:(NSDictionary *)challengeDict withPoints:(NSDictionary *)pointsDict {
    self.chellange = [[Challenge alloc] initWithDictionary:challengeDict];
    [self.chellange fillPoints:pointsDict];
}

- (void)setOutcome:(BOOL)outcome {
    _outcome = outcome;
    self.hasOutcome = YES;
}

- (BOOL)isExpired {
    return [self.expirationDate timeIntervalSinceNow] < 0;
}

- (BOOL)isFinished {
    return self.chellange.isOwn && [self.expirationDate timeIntervalSinceNow] < 0;
}


- (BOOL) passed72HoursSinceExpiration
{
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.resolutionDate];
    NSTimeInterval secondsIn72Hours = 60 * 60 * 72;
    
    if (timeInterval > secondsIn72Hours)
    {
        return YES;
    }
    
    return NO;
}

- (BOOL)canSetOutcome {
    return self.chellange && ([self isFinished] || [self passed72HoursSinceExpiration]);
}

- (NSString *)metaDataString {
    NSString* expirationString = [self predictionExpiresIntervalString: self];
    NSString* creationString = [self predictionCreatedIntervalString: self];
    
    return [NSString stringWithFormat: NSLocalizedString(@"%@ | %@ | %d%% agree |", @""),
            expirationString,
            creationString,
            self.agreedPercent];
}
#pragma mark Calculate dates


- (NSString*) predictionCreatedIntervalString: (Prediction*) prediciton
{
    NSString* result;
    
    NSDate* now = [NSDate date];
    
    NSTimeInterval interval = [now timeIntervalSinceDate: prediciton.creationDate];
    
    NSInteger secondsInMinute = 60;
    NSInteger minutesInHour = 60;
    NSInteger hoursInDay = 24;
    NSInteger daysInMonth = 30;
    NSInteger monthInYear = 12;
    
    if (interval < secondsInMinute)
    {
        result = [NSString stringWithFormat: NSLocalizedString(@"made %ds ago", @""), (NSInteger)interval];
    }
    else if (interval < (secondsInMinute * minutesInHour * hoursInDay))
    {
        NSInteger minutes = 0;
        NSInteger hours = (NSInteger)interval / (secondsInMinute * minutesInHour);
        minutes = hours > 0 ? 0 : ((NSInteger)interval / secondsInMinute) % minutesInHour;
        
        NSString* hoursString = (hours != 0) ? [NSString stringWithFormat: NSLocalizedString(@"%dh", @""), hours] : @"";
        NSString* minutesString = (minutes != 0) ? [NSString stringWithFormat: NSLocalizedString(@"%dm", @""), minutes] : @"";
        NSString* space = (hours != 0 && minutes != 0) ? @" " : @"";
        
        result = [NSString stringWithFormat: NSLocalizedString(@"made %@%@%@ ago", @""), hoursString, space, minutesString];
    }
    else if (interval < (secondsInMinute * minutesInHour * hoursInDay * daysInMonth))
    {
        NSInteger days = ((NSInteger)interval / (secondsInMinute * minutesInHour * hoursInDay));
        result = [NSString stringWithFormat: NSLocalizedString(@"made %dd ago", @""), days];
    }
    else if (interval < (secondsInMinute * minutesInHour * hoursInDay * daysInMonth * monthInYear))
    {
        NSInteger month = ((NSInteger)interval / (secondsInMinute * minutesInHour * hoursInDay * daysInMonth));
        result = [NSString stringWithFormat: NSLocalizedString(@"made %dmth ago", @""), month];
    }
    else
    {
        NSInteger year = ((NSInteger)interval / (secondsInMinute * minutesInHour * hoursInDay * daysInMonth * monthInYear));
        result = [NSString stringWithFormat: NSLocalizedString(@"made %dyr%@ ago", @""), year, (year != 1) ? @"s" : @""];
    }
    
    return result;
}


- (NSString*) predictionExpiresIntervalString: (Prediction*) prediciton {
    NSString* result;
    
    NSTimeInterval interval = 0;
    NSDate* now = [NSDate date];
    BOOL expired = NO;
    
    if ([now compare: prediciton.expirationDate] == NSOrderedAscending)
    {
        interval = [prediciton.expirationDate timeIntervalSinceDate: now];
    }
    else
    {
        interval = [now timeIntervalSinceDate: prediciton.expirationDate];
        expired = YES;
    }
    
    NSInteger secondsInMinute = 60;
    NSInteger minutesInHour = 60;
    NSInteger hoursInDay = 24;
    NSInteger daysInMonth = 30;
    NSInteger monthInYear = 12;
    
    if (interval < secondsInMinute)
    {
        result = [NSString stringWithFormat: NSLocalizedString(@"exp %ds%@", @""), (NSInteger)interval, (expired) ? @" ago" : @""];
    }
    else if (interval < (secondsInMinute * minutesInHour * hoursInDay))
    {
        NSInteger minutes = 0;
        NSInteger hours = (NSInteger)interval / (secondsInMinute * minutesInHour);
        minutes = hours > 0 ? 0 : ((NSInteger)interval / secondsInMinute) % minutesInHour;
        
        NSString* hoursString = (hours != 0) ? [NSString stringWithFormat: NSLocalizedString(@"%dh", @""), hours] : @"";
        NSString* minutesString = (minutes != 0) ? [NSString stringWithFormat: NSLocalizedString(@"%dm", @""), minutes] : @"";
        NSString* space = (hours != 0 && minutes != 0) ? @" " : @"";
        
        result = [NSString stringWithFormat: NSLocalizedString(@"exp %@%@%@%@", @""), hoursString, space, minutesString, (expired) ? @" ago" : @""];
    }
    else if (interval < (secondsInMinute * minutesInHour * hoursInDay * daysInMonth))
    {
        NSInteger days = ((NSInteger)interval / (secondsInMinute * minutesInHour * hoursInDay)) + 1;
        result = [NSString stringWithFormat: NSLocalizedString(@"exp %dd%@", @""), days, (expired) ? @" ago" : @""];
    }
    else if (interval < (secondsInMinute * minutesInHour * hoursInDay * daysInMonth * monthInYear))
    {
        NSInteger month = ((NSInteger)interval / (secondsInMinute * minutesInHour * hoursInDay * daysInMonth)) + 1;
        result = [NSString stringWithFormat: NSLocalizedString(@"exp %dmth%@", @""), month, (expired) ? @" ago" : @""];
    }
    else
    {
        NSInteger year = ((NSInteger)interval / (secondsInMinute * minutesInHour * hoursInDay * daysInMonth * monthInYear)) + 1;
        result = [NSString stringWithFormat: NSLocalizedString(@"exp %dyr%@", @""), year, (year != 1) ? @"s" : @"", (expired) ? @" ago" : @""];
    }

    
    return result;
}

- (BOOL)iAgree {
    return (self.chellange != nil) && (self.chellange.agree);
}

- (BOOL)iDisagree {
    return (self.chellange != nil) && !(self.chellange.agree);
}

- (UIImage *)statusImage {
    if ([self iAgree])
        return [UIImage imageNamed:@"AgreeMarker"];
    else if ([self iDisagree])
        return [UIImage imageNamed:@"DisagreeMarker"];
    else
        return nil;
}

- (NSString *)outcomeString {
    if ([self iAgree])
        return self.outcome ? @"W" : @"L";
    else if ([self iDisagree])
        return self.outcome ? @"L" : @"W";
    return nil;
}
- (BOOL)win {
    if ([self iAgree])
        return self.outcome ? YES : NO;
    else
        return self.outcome ? NO : YES;
}
- (NSString *)pointsString {
    __block NSMutableString *string = [NSMutableString string];
    
    void (^addPoint)(int, NSString*) = ^(int point, NSString *name) {
        if(point > 0) {
            [string appendFormat:@"+%d %@\n", point, name];
        }
    };
    
    addPoint(self.chellange.basePoints, NSLocalizedString(@"Base", @""));
    addPoint(self.chellange.outcomePoints, NSLocalizedString(@"Outcome", @""));
    addPoint(self.chellange.marketSizePoints, NSLocalizedString(@"Market size", @""));
    addPoint(self.chellange.predictionMarketPoints, [self marketSizeNameForPoints:self.chellange.predictionMarketPoints]);
    
    return string;
}
- (NSInteger)totalPoints {
    return self.chellange.basePoints + self.chellange.outcomePoints + self.chellange.marketSizePoints + self.chellange.predictionMarketPoints;
}
- (NSString *)marketSizeNameForPoints:(NSInteger)points {
    switch (points) {
        case 0:  return NSLocalizedString(@"Too Easy", @"");
        case 10:
        case 20: return NSLocalizedString(@"Favorite", @"");
        case 30:
        case 40: return NSLocalizedString(@"Underdog", @"");
        case 50: return NSLocalizedString(@"Longshot", @"");
        default: return @"";
    }
}

@end
