//
//  OutcomeWebRequest.m
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 14.08.13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "OutcomeWebRequest.h"

@interface OutcomeWebRequest() {
    NSInteger _predictionId;
    BOOL      _realise;
}

@end

@implementation OutcomeWebRequest

- (id)initWithPredictionId:(NSInteger)predictionId realise:(BOOL)realise {
    if(self = [super init]) {
        _predictionId = predictionId;
        _realise      = realise;
    }
    return self;
}

- (NSString *)methodName {
    NSString *format = _realise ? @"predictions/%d/realize.json" : @"predictions/%d/unrealize.json";
    return [NSString stringWithFormat:format, _predictionId];
}

- (NSString *)httpMethod {
    return @"POST";
}

- (BOOL)requiresAuthToken {
    return YES;
}

@end
