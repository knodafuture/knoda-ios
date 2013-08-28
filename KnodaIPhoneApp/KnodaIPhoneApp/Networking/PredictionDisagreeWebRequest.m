//
//  PredictionDisagreeWebRequest.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 8/13/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "PredictionDisagreeWebRequest.h"
#import "BadgesWebRequest.h"


@interface PredictionDisagreeWebRequest ()

@property (nonatomic, assign) NSInteger predictionID;

@end


@implementation PredictionDisagreeWebRequest


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
    return [NSString stringWithFormat: @"predictions/%d/disagree.json", self.predictionID];
}


- (NSString*) httpMethod
{
    return @"POST";
}


- (BOOL) requiresAuthToken
{
    return YES;
}

- (NSString *)userFriendlyErrorDescription {
    return NSLocalizedString(@"Unable to disagree this prediction at this time. Please try again later.", @"");
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
