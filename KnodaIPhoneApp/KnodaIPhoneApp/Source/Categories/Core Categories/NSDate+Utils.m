//
//  NSDate+Utils.m
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 15.08.13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "NSDate+Utils.h"

NSString* const kDateFormat = @"yyyy-MM-dd HH:mm";

static const NSUInteger kYearMonthDayUnits = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
static const NSUInteger kHourMinute        = NSHourCalendarUnit | NSMinuteCalendarUnit;

@implementation NSDate (Utils)

#pragma mark GMT DateFormatter

+ (NSDateFormatter *)gmtDateFormatter {
    static NSDateFormatter *gmtFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gmtFormatter          = [NSDateFormatter new];
        gmtFormatter.locale   = [NSLocale currentLocale];
        gmtFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    });
    return gmtFormatter;
}

- (NSString *)gmtStringWithFormat:(NSString *)format {
    NSDateFormatter *formatter = [[self class] gmtDateFormatter];
    formatter.dateFormat = format;
    return [formatter stringFromDate:self];
}

#pragma mark GMT Calendar

+ (NSCalendar *)gmtCalendar {
    static NSCalendar *gmtCalendar = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gmtCalendar          = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
        gmtCalendar.locale   = [NSLocale currentLocale];
        gmtCalendar.timeZone = [NSTimeZone timeZoneWithAbbreviation: @"GMT"];
    });
    return gmtCalendar;
}

- (NSDateComponents *)gmtDateComponents {
    return [[[self class] gmtCalendar] components:(kYearMonthDayUnits | kHourMinute)  fromDate:self];
}

#pragma mark -

+ (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter          = [NSDateFormatter new];
        formatter.locale   = [NSLocale currentLocale];
    });
    return formatter;
}

- (NSString *)stringWithFormat:(NSString *)format {
    NSDateFormatter *formatter = [[self class] dateFormatter];
    formatter.dateFormat = format;
    return [formatter stringFromDate:self];
}

+ (NSDate *)dateFromString:(NSString *)string withFormat:(NSString *)format {
    NSDateFormatter *formatter = [[self class] dateFormatter];
    formatter.dateFormat = format;
    return [formatter dateFromString:string];
}

@end
