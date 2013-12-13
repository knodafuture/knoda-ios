//
//  NewPrediction+Utils.m
//  KnodaIPhoneApp
//
//  Created by nick on 12/6/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "Prediction+Utils.h"
#import "Challenge.h"
#import "NSData+Utils.h"

@implementation Prediction (Utils)

+ (NSArray *)arrayFromHistoryData:(NSData *)data {
    
    if (!data)
        return nil;
    
    id jsonObject = [data jsonObject];
    
    if (!jsonObject || ![jsonObject isKindOfClass:NSDictionary.class])
        return nil;
    
    NSArray *challenges = jsonObject[@"challenges"];
    
    NSMutableArray *returnArray = [[NSMutableArray alloc] initWithCapacity:challenges.count];
    
    for (NSDictionary *challenge in challenges) {
        @autoreleasepool {
            NSMutableDictionary *mutableChallenge = [challenge mutableCopy];
            NSDictionary *prediction = mutableChallenge[@"prediction"];
            [mutableChallenge removeObjectForKey:@"prediction"];
            
            NSDictionary *pointsDictionary = mutableChallenge[@"points_details"];
            [mutableChallenge removeObjectForKey:@"points_details"];
            
            if (!prediction || ![prediction isKindOfClass:NSDictionary.class])
                continue;
            
            NSMutableDictionary *copy = [prediction mutableCopy];
            [copy setObject:[NSDictionary dictionaryWithDictionary:mutableChallenge] forKey:@"my_challenge"];
            [copy setObject:pointsDictionary forKey:@"my_points"];
            
            [returnArray addObject:[self instanceFromDictionary:copy]];
        }
    }
    
    return [NSArray arrayWithArray:returnArray];
}

- (BOOL)isExpired {
    return [self.expirationDate timeIntervalSinceNow] < 0;
}

- (BOOL)isFinished {
    return self.challenge.isOwn && [self.resolutionDate timeIntervalSinceNow] < 0;
}

- (BOOL)passed72HoursSinceExpiration {
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.resolutionDate];
    NSTimeInterval secondsIn72Hours = 60 * 60 * 72;
    
    if (timeInterval > secondsIn72Hours)
        return YES;
    
    return NO;
}

- (BOOL)canSetOutcome {
    return self.challenge && ([self isFinished] || [self passed72HoursSinceExpiration]);
}

- (NSString *)metaDataString {
    NSString* expirationString = [self predictionExpiresIntervalString];
    NSString* creationString = [self predictionCreatedIntervalString];
    
    CGFloat agreedFloat = ((CGFloat)self.agreeCount / (CGFloat)(self.agreeCount+self.disagreeCount));
    NSInteger agreedPercent = agreedFloat * 100;
    
    return [NSString stringWithFormat: NSLocalizedString(@"%@ | %@ | %d%% agree |", @""),
            expirationString,
            creationString,
             agreedPercent];
}
#pragma mark Calculate dates


- (NSString *)predictionCreatedIntervalString {
    NSString* result;
    
    NSDate* now = [NSDate date];
    
    NSTimeInterval interval = [now timeIntervalSinceDate:self.creationDate];
    
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
        result = [NSString stringWithFormat: NSLocalizedString(@"made %dmo ago", @""), month];
    }
    else
    {
        NSInteger year = ((NSInteger)interval / (secondsInMinute * minutesInHour * hoursInDay * daysInMonth * monthInYear));
        result = [NSString stringWithFormat: NSLocalizedString(@"made %dyr%@ ago", @""), year, (year != 1) ? @"s" : @""];
    }
    
    return result;
}


- (NSString *) predictionExpiresIntervalString {
    NSString* result;
    
    NSTimeInterval interval = 0;
    NSDate* now = [NSDate date];
    BOOL expired = NO;
    
    if ([now compare:self.expirationDate] == NSOrderedAscending)
        interval = [self.expirationDate timeIntervalSinceDate: now];
    else
    {
        interval = [now timeIntervalSinceDate:self.expirationDate];
        expired = YES;
    }
    
    NSInteger secondsInMinute = 60;
    NSInteger minutesInHour = 60;
    NSInteger hoursInDay = 24;
    NSInteger daysInMonth = 30;
    NSInteger monthInYear = 12;
    
    if (interval < secondsInMinute)
    {
        result = [NSString stringWithFormat: expired ? NSLocalizedString(@"closed %ds%@", @"") : NSLocalizedString(@"closes %ds%@", @""), (NSInteger)interval, (expired) ? @" ago" : @""];
    }
    else if (interval < (secondsInMinute * minutesInHour * hoursInDay))
    {
        NSInteger minutes = 0;
        NSInteger hours = (NSInteger)interval / (secondsInMinute * minutesInHour);
        minutes = hours > 0 ? 0 : ((NSInteger)interval / secondsInMinute) % minutesInHour;
        
        NSString* hoursString = (hours != 0) ? [NSString stringWithFormat: NSLocalizedString(@"%dh", @""), hours] : @"";
        NSString* minutesString = (minutes != 0) ? [NSString stringWithFormat: NSLocalizedString(@"%dm", @""), minutes] : @"";
        NSString* space = (hours != 0 && minutes != 0) ? @" " : @"";
        
        result = [NSString stringWithFormat: expired ? NSLocalizedString(@"closed %@%@%@%@", @"") : NSLocalizedString(@"closes %@%@%@%@", @""), hoursString, space, minutesString, (expired) ? @" ago" : @""];
    }
    else if (interval < (secondsInMinute * minutesInHour * hoursInDay * daysInMonth))
    {
        NSInteger days = ((NSInteger)interval / (secondsInMinute * minutesInHour * hoursInDay)) + 1;
        result = [NSString stringWithFormat: expired? NSLocalizedString(@"closed %dd%@", @"") : NSLocalizedString(@"closes %dd%@", @""), days, (expired) ? @" ago" : @""];
    }
    else if (interval < (secondsInMinute * minutesInHour * hoursInDay * daysInMonth * monthInYear))
    {
        NSInteger month = ((NSInteger)interval / (secondsInMinute * minutesInHour * hoursInDay * daysInMonth)) + 1;
        result = [NSString stringWithFormat: expired? NSLocalizedString(@"closed %dmo%@", @"") : NSLocalizedString(@"closes %dmo%@", @""), month, (expired) ? @" ago" : @""];
    }
    else
    {
        NSInteger year = ((NSInteger)interval / (secondsInMinute * minutesInHour * hoursInDay * daysInMonth * monthInYear)) + 1;
        result = [NSString stringWithFormat: expired ? NSLocalizedString(@"closed %dyr%@", @"") : NSLocalizedString(@"closes %dyr%@", @""), year, (year != 1) ? @"s" : @"", (expired) ? @" ago" : @""];
    }
    
    
    return result;
}

- (BOOL)iAgree {
    return (self.challenge != nil) && (self.challenge.agree);
}

- (BOOL)iDisagree {
    return (self.challenge != nil) && !(self.challenge.agree);
}

- (UIImage *)statusImage {
    if (self.challenge.isOwn)
        return nil;
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
    
    addPoint(self.challenge.basePoints, NSLocalizedString(@"Base", @""));
    addPoint(self.challenge.outcomePoints, NSLocalizedString(@"Outcome", @""));
    addPoint(self.challenge.marketSizePoints, NSLocalizedString(@"Market", @""));
    addPoint(self.challenge.predictionMarketPoints, [self marketSizeNameForPoints:self.challenge.predictionMarketPoints]);
    
    return string;
}
- (NSInteger)totalPoints {
    return self.challenge.basePoints + self.challenge.outcomePoints + self.challenge.marketSizePoints + self.challenge.predictionMarketPoints;
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
