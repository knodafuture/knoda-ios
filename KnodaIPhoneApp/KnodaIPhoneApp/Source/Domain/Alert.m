//
//  Alert.m
//  KnodaIPhoneApp
//
//  Created by nick on 12/11/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "Alert.h"

@implementation Alert

+ (NSString *)responseKey {
    return @"activityfeed";
}

+ (id)instanceFromDictionary:(NSDictionary *)dictionary {
    
    Alert *alert = [super instanceFromDictionary:dictionary];
    
    if (!alert)
        return nil;
    
    alert.alertId = [dictionary[@"id"] integerValue];
    alert.predictionId = [dictionary[@"prediction_id"] integerValue];
    alert.userId = [dictionary[@"user_id"] integerValue];
    
    alert.creationDate = [alert dateFromObject:dictionary[@"created_at"]];
    alert.predictionBody = dictionary[@"prediction_body"];
    alert.title = dictionary[@"title"];
    
    alert.seen = [dictionary[@"seen"] boolValue];
    
    NSString *type = dictionary[@"activity_type"];
    
    if ([type isEqualToString:@"WON"])
        alert.alertType = AlertTypeWon;
    else if ([type isEqualToString:@"LOST"])
        alert.alertType = AlertTypeLost;
    else if ([type isEqualToString:@"COMMENT"])
        alert.alertType = AlertTypeComment;
    else if ([type isEqualToString:@"EXPIRED"])
        alert.alertType = AlertTypeExpired;
    
    return alert;
}

- (NSString *)createdAtString {
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

- (UIImage *)image {
    switch (self.alertType) {
        case AlertTypeComment:
            return [UIImage imageNamed:@"ActivityCommentIcon"];
            break;
        case AlertTypeExpired:
            return [UIImage imageNamed:@"ActivityExpiredIcon"];
            break;
        case AlertTypeWon:
            return [UIImage imageNamed:@"ActivityWonIcon"];
            break;
        case AlertTypeLost:
            return [UIImage imageNamed:@"ActivityLostIcon"];
        default:
            return nil;
            break;
    }
}

@end
