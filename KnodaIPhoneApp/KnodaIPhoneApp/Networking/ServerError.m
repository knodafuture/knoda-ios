//
//  ServerError.m
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 29.08.13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "ServerError.h"

NSString* const kServerErrorDomain = @"ServerErroDomain";

static NSArray *_errorKeys;
static NSArray *_errorValues;

@interface ServerError() {
    NSMutableArray *_descriptions;
}

@end

@implementation ServerError

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _errorKeys = @[@"email",
                       @"password",
                       @"username",
                       @"token",
                       @"body"];
        
        _errorValues = @[@"has already been taken",
                         @"is invalid",
                         @"is blank",
                         @"is too short (minimum is 6 characters)",
                         @"is too long (maximum is 20 characters)"];
    });
}

- (id)initWithCode:(NSInteger)code andInfo:(NSDictionary *)dict {
    if(self = [super initWithDomain:kServerErrorDomain code:code userInfo:dict]) {
        
        _descriptions = [NSMutableArray arrayWithCapacity:dict.count];
        
        [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            
            NSString *objString = [obj isKindOfClass:[NSArray class]] ? [obj lastObject] : obj;
            
            if([_errorKeys containsObject:key] && [_errorValues containsObject:objString]) {
                NSString *desc = [NSString stringWithFormat:@"%@ %@", key, objString];
                desc = NSLocalizedString(desc, @"");
                if(desc.length) {
                    [_descriptions addObject:desc];
                }
            }
            else {
                DLog(@"unknnown server error: %@ : %@", key, objString);
            }
        }];
    }
    return self;
}

- (BOOL)shouldNotifyUser {
    return _descriptions.count > 0;
}

- (NSArray *)localizedDescriptionsArray {
    return [NSArray arrayWithArray:_descriptions];
}

- (NSString *)localizedDescription {
    return _descriptions.count ? [_descriptions objectAtIndex:0] : @"";
}

@end
