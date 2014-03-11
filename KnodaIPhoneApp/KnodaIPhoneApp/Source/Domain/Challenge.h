//
//  NewChallenge.h
//  KnodaIPhoneApp
//
//  Created by nick on 12/6/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "WebObject.h"

@class PredictionPoints;

@interface Challenge : WebObject

@property (assign, nonatomic) NSInteger challengeId;
@property (assign, nonatomic) BOOL seen;
@property (assign, nonatomic) BOOL agree;
@property (assign, nonatomic) BOOL isOwn;
@property (assign, nonatomic) BOOL isRight;
@property (assign, nonatomic) BOOL isFinished;
@property (assign, nonatomic) BOOL isBS;
@property (assign, nonatomic) NSInteger basePoints;
@end
