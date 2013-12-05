//
//  NewPrediction.h
//  KnodaIPhoneApp
//
//  Created by nick on 12/6/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "WebObject.h"

@class Challenge;
@interface Prediction : WebObject
@property (assign, nonatomic) NSInteger predictionId;
@property (strong, nonatomic) NSString *category;
@property (strong, nonatomic) NSString *body;
@property (strong, nonatomic) NSDate *creationDate;
@property (strong, nonatomic) NSDate *expirationDate;
@property (strong, nonatomic) NSDate *resolutionDate;

@property (assign, nonatomic) NSInteger agreeCount;
@property (assign, nonatomic) NSInteger disagreeCount;
@property (assign, nonatomic) NSInteger agreedPercent;
@property (assign, nonatomic) NSInteger votedUsersCount;

@property (assign, nonatomic) NSInteger userId;
@property (strong, nonatomic) NSString *userName;
@property (assign, nonatomic) NSInteger commentCount;

@property (strong, nonatomic) NSString *shortUrl;
@property (strong, nonatomic) NSString *thumbAvatarUrl;
@property (strong, nonatomic) NSString *smallAvatarUrl;
@property (strong, nonatomic) NSString *largeAvatarUrl;

@property (strong, nonatomic) Challenge *challenge;

@property (assign, nonatomic) BOOL expired;
@property (assign, nonatomic) BOOL hasOutcome;
@property (assign, nonatomic) BOOL outcome;
@property (assign, nonatomic) BOOL settled;
@property (assign, nonatomic) BOOL isReadyForResolution;

@end
