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
{
    NSDictionary* theParams = @{@"prediction[body]" : @"New prediction",
                                @"prediction[expires_at(1i)]" : [NSNumber numberWithInteger: year],
                                @"prediction[expires_at(2i)]" : [NSNumber numberWithInteger: month],
                                @"prediction[expires_at(3i)]" : [NSNumber numberWithInteger: day],
                                @"prediction[outcome]" : [NSNumber numberWithBool: NO], @"prediction[tag_list]" : @"dsfds, sdfdsf"};
    
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
