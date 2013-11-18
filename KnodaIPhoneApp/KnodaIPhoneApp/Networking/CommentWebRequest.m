//
//  CommentWebRequest.m
//  KnodaIPhoneApp
//
//  Created by Nick R on 11/17/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "CommentWebRequest.h"
#import "Comment.h"

@implementation CommentWebRequest
static const NSInteger kPageResultsLimit = 25;

+ (NSInteger) limitByPage
{
    return kPageResultsLimit;
}

- (id)initWithOffset:(NSInteger)offset forPredictionId:(NSInteger)predictionId {
    NSDictionary* params = @{@"list": @"prediction",
                             @"limit" : [NSNumber numberWithInteger: kPageResultsLimit],
                             @"offset" : [NSNumber numberWithInteger: offset],
                             @"prediction_id": [NSNumber numberWithInt:predictionId]};
    
    self = [super initWithParameters:params];
    
    return self;

}
- (id)initWithLastId:(NSInteger)lastId forPredictionId:(NSInteger)predictionId
{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithDictionary:
                                   @{@"recent": @"true",
                                     @"limit" : @(kPageResultsLimit),
                                     @"id_lt" : @(lastId)}];

    self = [super initWithParameters: params];
    return self;
}
- (NSString*) methodName
{
    return @"comments.json";
}


- (void) fillResultObject: (id) parsedResult
{
    
    NSMutableArray* commentsArray = [[NSMutableArray alloc] initWithCapacity: 0];
    
    NSArray* resultArray = [parsedResult objectForKey: @"comments"];
    
    for (NSDictionary* commentsDictionary in resultArray)
    {
        Comment *comment = [[Comment alloc] initWithDictionary:commentsDictionary];
        
        [commentsArray addObject: comment];
    }
    
    self.comments = commentsArray;
}


- (BOOL) requiresAuthToken
{
    return YES;
}

@end
