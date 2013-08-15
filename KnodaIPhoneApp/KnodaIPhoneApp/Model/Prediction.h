//
//  Prediction.h
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/9/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Chellange;

@interface Prediction : NSObject

@property (nonatomic, assign) NSInteger ID;
@property (nonatomic, copy) NSString* category;
@property (nonatomic, copy) NSString* body;
@property (nonatomic, strong) NSDate* creationDate;
@property (nonatomic, strong) NSDate* expirationDate;
@property (nonatomic, assign) NSInteger agreeCount;
@property (nonatomic, assign) NSInteger disagreeCount;
@property (nonatomic, assign) NSInteger voitedUsersCount;
@property (nonatomic, assign) NSInteger agreedPercent;
@property (nonatomic, assign) BOOL expired;
@property (nonatomic, assign) BOOL outcome;
@property (nonatomic, assign) BOOL settled;
@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, copy) NSString* userName;
@property (nonatomic, strong) NSURL* userAvatarURL;
@property (nonatomic, strong) UIImage* userAvatar;
@property (nonatomic, strong) Chellange* chellange;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
