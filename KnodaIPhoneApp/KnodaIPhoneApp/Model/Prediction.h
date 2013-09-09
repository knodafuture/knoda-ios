//
//  Prediction.h
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/9/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "BaseModelObject.h"

@class Chellange;

@interface Prediction : BaseModelObject

@property (nonatomic, assign) NSInteger ID;
@property (nonatomic, copy) NSString* category;
@property (nonatomic, copy) NSString* body;
@property (nonatomic, strong) NSDate* creationDate;
@property (nonatomic, strong) NSDate* expirationDate;
@property (nonatomic ,strong) NSDate* unfinishedDate;
@property (nonatomic, assign) NSInteger agreeCount;
@property (nonatomic, assign) NSInteger disagreeCount;
@property (nonatomic, assign) NSInteger voitedUsersCount;
@property (nonatomic, assign) NSInteger agreedPercent;
@property (nonatomic, assign) BOOL expired;
@property (nonatomic, assign) BOOL hasOutcome;
@property (nonatomic, assign) BOOL outcome;
@property (nonatomic, assign) BOOL settled;
@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, copy) NSString* userName;
@property (nonatomic, strong) Chellange* chellange;

@property (nonatomic) NSString *thumbAvatar;
@property (nonatomic) NSString *smallAvatar;
@property (nonatomic) NSString *bigAvatar;

- (id)initWithDictionary:(NSDictionary *)dictionary;

- (void)setupChallenge:(NSDictionary *)challengeDict withPoints:(NSDictionary *)pointsDict;

- (BOOL)isExpired;

- (BOOL)isFinished;

- (BOOL) passed72HoursSinceExpiration;

- (BOOL)canSetOutcome;

@end
