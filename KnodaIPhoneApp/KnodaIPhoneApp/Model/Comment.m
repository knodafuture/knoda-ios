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

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    self._id = [dictionary[@"id"] intValue];
    self.userId = [dictionary[@"user_id"] intValue];
    self.predictionId = [dictionary[@"prediction_id"] intValue];
    self.body = dictionary[@"text"];
    if ([self.body isKindOfClass:NSNull.class])
        self.body = @"";
    self.createdDate = [self dateFromObject:dictionary[@"created_at"]];
    self.challenge = [[Challenge alloc] initWithDictionary:dictionary[@"challenge"]];
    self.username = dictionary[@"username"];
    NSDictionary *imageDictionary = dictionary[@"user_avatar"];
    
    if ([imageDictionary isKindOfClass:[NSDictionary class]]) {
        self.thumbUserImage = imageDictionary[@"thumb"];
        self.smallUserImage = imageDictionary[@"small"];
        self.bigUserImage   = imageDictionary[@"big"];
    }
    
    return self;
}

- (NSString *)createdAtString {

    NSString* result;
    
    NSDate* now = [NSDate date];
    
    NSTimeInterval interval = [now timeIntervalSinceDate: self.createdDate];
    
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
@end
