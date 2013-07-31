//
//  AddPredictionRequest.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/12/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "AddPredictionRequest.h"

@implementation AddPredictionRequest


- (id) initWithBody: (NSString*) body
      expirationDay: (NSInteger) day
    expirationMonth: (NSInteger) month
     expirationYear: (NSInteger) year
     expirationHour: (NSInteger) hour
   expirationMinute: (NSInteger) minute
           category: (NSString*) category
{
    NSDictionary* theParams = @{@"prediction[body]" : body,
                                @"prediction[expires_at(1i)]" : [NSNumber numberWithInteger: year],
                                @"prediction[expires_at(2i)]" : [NSNumber numberWithInteger: month],
                                @"prediction[expires_at(3i)]" : [NSNumber numberWithInteger: day],
                                @"prediction[expires_at(4i)]" : [NSNumber numberWithInteger: hour],
                                @"prediction[expires_at(5i)]" : [NSNumber numberWithInteger: minute],
                                @"prediction[tag_list][]" : category};
    
    self = [super initWithParameters: theParams];
    return self;
}


- (NSString*) methodName
{
    return @"predictions.json";
}


- (void) fillResultObject: (id) parsedResult
{
    NSLog(@"Add Prediction Result: %@", parsedResult);
}


- (NSString*) httpMethod
{
    return @"POST";
}


- (BOOL) requiresAuthToken
{
    return YES;
}


@end
