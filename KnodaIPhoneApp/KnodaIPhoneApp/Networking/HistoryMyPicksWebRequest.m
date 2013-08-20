//
//  HistoryMyPicksWebRequest.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 8/14/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "HistoryMyPicksWebRequest.h"
#import "Prediction.h"
#import "Chellange.h"


static const NSInteger kPageResultsLimit = 7;


@implementation HistoryMyPicksWebRequest

+ (NSInteger) limitByPage
{
    return kPageResultsLimit;
}


- (id) init
{
    NSDictionary* params = @{@"list": @"picks"};
    
    self = [super initWithParameters: params];
    return self;
}


- (id) initWithLastCreatedDate: (NSDate*) lastCreatedDate
{
    NSDictionary* params = @{@"list": @"picks", @"limit" : [NSNumber numberWithInteger: kPageResultsLimit], @"created_at_lt" : lastCreatedDate};
    
    self = [super initWithParameters: params];
    return self;
}


- (NSString*) methodName
{
    return @"challenges.json";
}


- (BOOL) requiresAuthToken
{
    return YES;
}


- (void) fillResultObject: (id) parsedResult
{
    NSLog(@"My picks result: %@", parsedResult);
    
    NSMutableArray* predictionsMutable = [NSMutableArray arrayWithCapacity: 0];
    
    NSArray* challengeArray = [parsedResult objectForKey: @"challenges"];
    
    for (NSDictionary* challengeDictionary in challengeArray)
    {
        Chellange* chellange = [[Chellange alloc] initWithDictionary:challengeDictionary];
        
        NSDictionary* pointsDictionary = [challengeDictionary objectForKey: @"points_details"];
        
        [chellange fillPoints:pointsDictionary];
        
        NSDictionary* predictionDictionary = [challengeDictionary objectForKey: @"prediction"];
        Prediction* prediction = [[Prediction alloc] init];
        
        prediction.ID = [[predictionDictionary objectForKey: @"id"] integerValue];
        prediction.body = [predictionDictionary objectForKey: @"body"];
        prediction.category = [[[predictionDictionary objectForKey: @"tags"] objectAtIndex: 0] objectForKey: @"name"];
        prediction.agreeCount = [[predictionDictionary objectForKey: @"agreed_count"] integerValue];
        prediction.disagreeCount = [[predictionDictionary objectForKey: @"disagreed_count"] integerValue];
        prediction.voitedUsersCount = [[predictionDictionary objectForKey: @"market_size"] integerValue];
        prediction.agreedPercent = [[predictionDictionary objectForKey: @"prediction_market"] integerValue];
        prediction.expired = [[predictionDictionary objectForKey: @"expired"] boolValue];
        prediction.settled = [[predictionDictionary objectForKey: @"settled"] boolValue];
        prediction.userId = [[predictionDictionary objectForKey: @"user_id"] integerValue];
        prediction.userName = [predictionDictionary objectForKey: @"username"];
        
        if ([predictionDictionary objectForKey: @"user_avatar"] != nil && ![[predictionDictionary objectForKey: @"user_avatar"] isKindOfClass: [NSNull class]])
        {
            prediction.userAvatarURL = [NSURL URLWithString: [[predictionDictionary objectForKey: @"user_avatar"] objectForKey: @"small"]];
        }
        
        if (![[predictionDictionary objectForKey: @"outcome"] isKindOfClass: [NSNull class]])
        {
            prediction.outcome = [[predictionDictionary objectForKey: @"outcome"] boolValue];
        }
        
        if ([predictionDictionary objectForKey: @"created_at"] != nil && ![[predictionDictionary objectForKey: @"created_at"] isKindOfClass: [NSNull class]])
        {
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat: @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'zzz"];
            prediction.creationDate = [dateFormatter dateFromString: [[predictionDictionary objectForKey: @"created_at"] stringByAppendingString: @"GMT"]];
        }
        
        if ([predictionDictionary objectForKey: @"expires_at"] != nil && ![[predictionDictionary objectForKey: @"expires_at"] isKindOfClass: [NSNull class]])
        {
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat: @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'zzz"];
            prediction.expirationDate = [dateFormatter dateFromString: [[predictionDictionary objectForKey: @"expires_at"] stringByAppendingString: @"GMT"]];
        }
        
        prediction.chellange = chellange;
        
        [predictionsMutable addObject: prediction];
    }
    
    self.predictions = [NSArray arrayWithArray: predictionsMutable];
}

@end
