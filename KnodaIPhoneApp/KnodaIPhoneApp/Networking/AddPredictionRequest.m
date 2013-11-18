//
//  AddPredictionRequest.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/12/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "AddPredictionRequest.h"
#import "NSDate+Utils.h"
#import "BadgesWebRequest.h"

@implementation AddPredictionRequest

- (id)initWithBody:(NSString *)body expirationDate:(NSDate *)date category:(NSString *)category {    
    NSDateComponents *dc = [date gmtDateComponents];    
    NSDictionary *params = @{@"prediction[body]" : body,
                             @"prediction[expires_at(1i)]" : @(dc.year),
                             @"prediction[expires_at(2i)]" : @(dc.month),
                             @"prediction[expires_at(3i)]" : @(dc.day),
                             @"prediction[expires_at(4i)]" : @(dc.hour),
                             @"prediction[expires_at(5i)]" : @(dc.minute),
                             @"prediction[tag_list][]" : category};
    self = [super initWithParameters:params];
    return self;
}

- (NSString*) methodName
{
    return @"predictions.json";
}


- (void) fillResultObject: (id) parsedResult
{
}


- (NSString*) httpMethod
{
    return @"POST";
}


- (BOOL) requiresAuthToken
{
    return YES;
}

- (void)executeWithCompletionBlock:(RequestCompletionBlock)completion {
    RequestCompletionBlock block = completion ? [completion copy] : nil;
    [super executeWithCompletionBlock:^{
        if(block) {
            block();
        }
        if(self.isSucceeded) {
            [BadgesWebRequest checkNewBadges];
        }
    }];
}


@end
