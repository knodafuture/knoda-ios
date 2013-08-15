//
//  BSWebRequest.m
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 14.08.13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "BSWebRequest.h"

@interface BSWebRequest() {
    NSInteger _predictionId;
}

@end

@implementation BSWebRequest

- (id)initWithPredictionId:(NSInteger)predictionId {
    if(self = [super init]) {
        _predictionId = predictionId;
    }
    return self;
}

- (NSString *)methodName {
    return [NSString stringWithFormat:@"predictions/%d/bs.json", _predictionId];
}


- (NSString *)httpMethod {
    return @"POST";
}


- (BOOL)requiresAuthToken {
    return YES;
}

@end
