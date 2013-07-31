//
//  Chellange.h
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/30/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <Foundation/Foundation.h>


@class Prediction;


@interface Chellange : NSObject

@property (nonatomic, assign) NSInteger ID;
@property (nonatomic, assign) BOOL seen;
@property (nonatomic, assign) BOOL agree;
@property (nonatomic, assign) BOOL isOwn;
@property (nonatomic, assign) BOOL isRight;
@property (nonatomic, assign) BOOL isFinished;
@property (nonatomic, assign) NSInteger basePoints;
@property (nonatomic, assign) NSInteger outcomePoints;
@property (nonatomic, assign) NSInteger marketSizePoints;
@property (nonatomic, assign) NSInteger predictionMarketPoints;

@end
