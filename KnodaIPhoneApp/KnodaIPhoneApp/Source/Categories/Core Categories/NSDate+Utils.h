//
//  NSDate+Utils.h
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 15.08.13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const kDateFormat;

@interface NSDate (Utils)

- (NSString *)gmtStringWithFormat:(NSString *)format;

- (NSDateComponents *)gmtDateComponents;

- (NSString *)stringWithFormat:(NSString *)format;

+ (NSDate *)dateFromString:(NSString *)string withFormat:(NSString *)format;

@end
