//
//  LoginWebRequest.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/11/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "PredictionsWebRequest.h"

@implementation PredictionsWebRequest


- (NSString*) methodName
{
    return @"predictions.json";
}


- (void) fillResultObject: (id) parsedResult
{
    NSLog(@"Predictions Result: %@", parsedResult);
}


- (BOOL) requiresAuthToken
{
    return YES;
}


@end
