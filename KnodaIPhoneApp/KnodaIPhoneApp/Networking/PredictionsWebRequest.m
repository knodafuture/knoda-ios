//
//  LoginWebRequest.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/11/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "PredictionsWebRequest.h"
#import "Prediction.h"
#import "Chellange.h"


static const NSInteger kPageResultsLimit = 5;


@interface PredictionsWebRequest ()

@property (nonatomic, strong) NSArray* predictions;

@end


@implementation PredictionsWebRequest


- (id) initWithPageNumber: (NSInteger) page
{
    NSDictionary* params = @{@"recent": @"true", @"limit" : [NSNumber numberWithInteger: kPageResultsLimit], @"offset" : [NSNumber numberWithInteger: (page * kPageResultsLimit)]};
    
    self = [super initWithParameters: params];
    return self;
}


- (NSString*) methodName
{
    return @"predictions.json";
}


- (void) fillResultObject: (id) parsedResult
{
    NSLog(@"Predictions Result: %@", parsedResult);
    
    NSMutableArray* predictionArray = [[NSMutableArray alloc] initWithCapacity: 0];
    
    NSArray* resultArray = [parsedResult objectForKey: @"predictions"];
    
    for (NSDictionary* predictionDictionary in resultArray)
    {
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
            prediction.userAvatarURL = [NSURL URLWithString: [predictionDictionary objectForKey: @"user_avatar"]];
        }
        
        if (![[predictionDictionary objectForKey: @"outcome"] isKindOfClass: [NSNull class]])
        {
            prediction.outcome = [[predictionDictionary objectForKey: @"outcome"] boolValue];
        }
        
        if ([predictionDictionary objectForKey: @"created_at"] != nil && ![[predictionDictionary objectForKey: @"created_at"] isKindOfClass: [NSNull class]])
        {
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat: @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
            prediction.creationDate = [dateFormatter dateFromString: [predictionDictionary objectForKey: @"created_at"]];
        }
        
        if ([predictionDictionary objectForKey: @"expires_at"] != nil && ![[predictionDictionary objectForKey: @"expires_at"] isKindOfClass: [NSNull class]])
        {
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat: @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
            prediction.expirationDate = [dateFormatter dateFromString: [predictionDictionary objectForKey: @"expires_at"]];
        }
        
        if ([predictionDictionary objectForKey: @"my_challenge"] != nil && ![[predictionDictionary objectForKey: @"my_challenge"] isKindOfClass: [NSNull class]])
        {
            NSDictionary* chellangeDictionary = [predictionDictionary objectForKey: @"my_challenge"];
            
            Chellange* chellange = [[Chellange alloc] init];
            chellange.ID = [[chellangeDictionary objectForKey: @"id"] integerValue];
            chellange.seen = [[chellangeDictionary objectForKey: @"seen"] boolValue];
            chellange.agree = [[chellangeDictionary objectForKey: @"agree"] boolValue];
            chellange.isOwn = [[chellangeDictionary objectForKey: @"is_own"] boolValue];
            chellange.isRight = [[chellangeDictionary objectForKey: @"is_right"] boolValue];
            chellange.isFinished = [[chellangeDictionary objectForKey: @"is_finished"] boolValue];
            
            NSDictionary* pointsDictionary = [chellangeDictionary objectForKey: @"my_points"];
            
            chellange.basePoints = [[pointsDictionary objectForKey: @"base_points"] integerValue];
            chellange.marketSizePoints = [[pointsDictionary objectForKey: @"market_size_points"] integerValue];
            chellange.outcomePoints = [[pointsDictionary objectForKey: @"outcome_points"] integerValue];
            chellange.predictionMarketPoints = [[pointsDictionary objectForKey: @"prediction_market_points"] integerValue];
        }
        
        [predictionArray addObject: prediction];
    }
    
    self.predictions = [NSArray arrayWithArray: predictionArray];
}


- (BOOL) requiresAuthToken
{
    return YES;
}


@end
