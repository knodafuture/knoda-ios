//
//  RemoveTokenWebRequest.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 9/2/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "RemoveTokenWebRequest.h"


@interface RemoveTokenWebRequest ()

@property (nonatomic, strong) NSNumber* tokenID;

@end



@implementation RemoveTokenWebRequest


- (id) initWithTokenID: (NSNumber*) tokenID
{
    self = [super init];
    
    if (self != nil)
    {
        self.tokenID = tokenID;
    }
    
    return self;
}


- (NSString*) methodName
{
    return [NSString stringWithFormat: @"apple_device_tokens/%d.json", [self.tokenID integerValue]];
}


- (NSString*) httpMethod
{
    return @"DELETE";
}


- (BOOL) requiresAuthToken
{
    return YES;
}


@end
