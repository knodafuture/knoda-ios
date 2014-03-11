//
//  NewPrediction.h
//  KnodaIPhoneApp
//
//  Created by nick on 12/6/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "WebObject.h"

@class Challenge;
@class RemoteImage;
@class PredictionPoints;

@interface Prediction : WebObject
@property (assign, nonatomic) NSInteger predictionId;
@property (strong, nonatomic) NSString *body;

@property (strong, nonatomic) NSArray *categories;

@property (strong, nonatomic) NSDate *creationDate;
@property (strong, nonatomic) NSDate *expirationDate;
@property (strong, nonatomic) NSDate *resolutionDate;
@property (strong, nonatomic) NSDate *closeDate;

@property (assign, nonatomic) NSInteger agreeCount;
@property (assign, nonatomic) NSInteger disagreeCount;

@property (assign, nonatomic) NSInteger userId;
@property (strong, nonatomic) NSString *username;
@property (assign, nonatomic) NSInteger commentCount;

@property (strong, nonatomic) RemoteImage *userAvatar;
@property (strong, nonatomic) NSString *shortUrl;
@property (strong, nonatomic) PredictionPoints *points;

@property (assign, nonatomic) BOOL verifiedAccount;

@property (strong, nonatomic) Challenge *challenge;

@property (assign, nonatomic) BOOL expired;
@property (assign, nonatomic) BOOL outcome;
@property (assign, nonatomic) BOOL settled;
@property (assign, nonatomic) BOOL isReadyForResolution;

@end
