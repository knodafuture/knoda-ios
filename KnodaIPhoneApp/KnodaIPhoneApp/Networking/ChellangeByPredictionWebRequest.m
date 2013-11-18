//
//  ChellangeByPredictionWebRequest.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 8/13/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "ChellangeByPredictionWebRequest.h"


@interface ChellangeByPredictionWebRequest ()

@property (nonatomic, assign) NSInteger predictionID;

@end


@implementation ChellangeByPredictionWebRequest

- (id) initWithPredictionID: (NSInteger) predictionID
{
    self = [super init];
    
    if (self != nil)
    {
        self.predictionID = predictionID;
    }
    
    return self;
}


- (NSString*) methodName
{
    return [NSString stringWithFormat: @"predictions/%d/challenge.json", self.predictionID];
}


- (BOOL) requiresAuthToken
{
    return YES;
}


- (void) fillResultObject: (id) parsedResult
{
    
    self.chellange = [[Challenge alloc] initWithDictionary:parsedResult];
}


@end
