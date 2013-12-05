//
//  NewChallenge.h
//  KnodaIPhoneApp
//
//  Created by nick on 12/6/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "WebObject.h"

@interface Challenge : WebObject

@property (nonatomic, assign) NSInteger challengeId;
@property (nonatomic, assign) BOOL seen;
@property (nonatomic, assign) BOOL agree;
@property (nonatomic, assign) BOOL isOwn;
@property (nonatomic, assign) BOOL isRight;
@property (nonatomic, assign) BOOL isFinished;
@property (nonatomic, assign) BOOL isBS;
@property (nonatomic, assign) NSInteger basePoints;
@property (nonatomic, assign) NSInteger outcomePoints;
@property (nonatomic, assign) NSInteger marketSizePoints;
@property (nonatomic, assign) NSInteger predictionMarketPoints;

@end
