//
//  ForgotPasswordWebRequest.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/26/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "ForgotPasswordWebRequest.h"

@implementation ForgotPasswordWebRequest

- (id) initWithEmail: (NSString*) email
{
    NSDictionary* theParameters = @{@"login" : email};
    
    self = [super initWithParameters: theParameters];
    return self;
}


- (NSString*) methodName
{
    return @"password.json";
}


- (NSString*) httpMethod
{
    return @"POST";
}


- (void) fillResultObject: (id) parsedResult
{
}


@end
