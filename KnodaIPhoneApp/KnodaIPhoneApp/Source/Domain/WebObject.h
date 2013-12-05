//
//  WebObject.h
//  KnodaIPhoneApp
//
//  Created by nick on 12/5/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *ResponseDateFormat;

@interface WebObject : NSObject


+ (id)instanceFromData:(NSData *)data;
+ (id)instanceFromDictionary:(NSDictionary *)dictionary;

+ (NSString *)responseKey;

+ (NSArray *)arrayFromData:(NSData *)data;
- (NSDictionary *)parametersDictionary;
- (NSDate *)dateFromObject:(id)obj;

@end
