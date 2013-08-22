//
//  AnotherUserProfileWebRequest.m
//  KnodaIPhoneApp
//
//  Created by Vyacheslav Nechiporenko on 8/22/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "AnotherUserProfileWebRequest.h"

@interface AnotherUserProfileWebRequest() {
    NSInteger _userId;
}

@end

@implementation AnotherUserProfileWebRequest

- (id)initWithUserId:(NSInteger)userId {
    if(self = [super init]) {
        _userId = userId;
    }
    return self;
}

- (NSString*) methodName
{
    NSString *format = @"users/%d.json";
    return [NSString stringWithFormat:format, _userId];
}

- (void) fillResultObject: (id) parsedResult
{
    NSLog(@"Parsed user's info: %@", parsedResult);
    
    if ([parsedResult respondsToSelector:@selector(valueForKey:)]) {
        self.user = [[User alloc]initWithDictionary:parsedResult];
    }
}

@end
