//
//  PredictionUsersWebRequest.m
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 14.08.13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "PredictionUsersWebRequest.h"
#import "NSDictionary+Utils.h"

@interface PredictionUsersWebRequest() {
    BOOL      _isForAgreed;
    NSInteger _predicionId;
}

@end

@implementation PredictionUsersWebRequest

- (id)initWithPredictionId:(NSInteger)predictionId forAgreedUsers:(BOOL)isForAgreed {
    if(self = [super init]) {
        _predicionId = predictionId;
        _isForAgreed = isForAgreed;
    }
    return self;
}

- (NSString *)methodName {
    NSString *format = _isForAgreed ? @"predictions/%d/history_agreed.json" : @"predictions/%d/history_disagreed.json";
    return [NSString stringWithFormat:format, _predicionId];
}

- (BOOL)requiresAuthToken {
    return YES;
}

- (void)fillResultObject:(id)parsedResult {
    DLog(@"%@", parsedResult);
    NSArray *challenged = [parsedResult objectForKey:@"challenges"];
    NSMutableArray *users = [NSMutableArray arrayWithCapacity:challenged.count];
    for(NSDictionary *user in challenged) {
        [users addObject:[user stringForKey:@"username"]];
    }
    self.users = [NSArray arrayWithArray:users];
}

@end
