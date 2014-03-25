//
//  ActivityItem+Utils.m
//  KnodaIPhoneApp
//
//  Created by nick on 3/11/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "ActivityItem+Utils.h"

@implementation ActivityItem (Utils)
- (NSString *)creationString {
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

- (NSString *)stripTag:(NSString *)tag fromString:(NSString *)string {
    NSString *openP = [string stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"<%@>", tag] withString:@""];
    return [openP stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"</%@>", tag] withString:@""];
}

- (NSAttributedString *)attributedText {
    NSString *stripped = [self stripTag:@"p" fromString:self.text];
    
    NSRange openRange = [stripped rangeOfString:@"<b>"];
    
    if (openRange.location == NSNotFound)
        return nil;
    
    NSRange endRange = [stripped rangeOfString:@"</b>"];
    
    if (endRange.location == NSNotFound)
        return nil;
    
    NSRange boldRange = NSMakeRange(openRange.location, endRange.location - 2);
    
    stripped = [self stripTag:@"b" fromString:stripped];
    
    NSDictionary *titleAttributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:13.0]};
    NSDictionary *bodyAttributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0]};
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:stripped attributes:nil];
    [string setAttributes:bodyAttributes range:NSMakeRange(0, string.length)];
    [string setAttributes:titleAttributes range:boldRange];

    return string;
}



@end
