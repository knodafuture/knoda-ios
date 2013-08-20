//
//  SetSeenAlertsWebRequest.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 8/20/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "SetSeenAlertsWebRequest.h"

@implementation SetSeenAlertsWebRequest


- (id) initWithIDs: (NSArray*) chellangeIDs
{
    NSMutableString* parameterString = [NSMutableString stringWithFormat: @"%d", [[chellangeIDs objectAtIndex: 0] integerValue]];
    
    for (int i = 1; i < chellangeIDs.count; i++)
    {
        NSNumber* chellangeID = [chellangeIDs objectAtIndex: i];
        [parameterString appendFormat: @"&ids[]=%d", [chellangeID integerValue]];
    }
    
    NSDictionary* params = @{@"ids[]=": parameterString};
    
    self = [super initWithParameters: params];
    return self;
}


- (NSString*) methodName
{
    return @"challenges/set_seen.json";
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
