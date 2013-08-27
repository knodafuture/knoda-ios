//
//  User.h
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/9/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "BaseModelObject.h"

@interface User : BaseModelObject

@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* email;
@property (nonatomic, strong) NSString* token;
@property (nonatomic, assign) NSUInteger points;
@property (nonatomic, assign) NSUInteger won;
@property (nonatomic, assign) NSUInteger lost;
@property (nonatomic, strong) NSNumber * winningPercentage;
@property (nonatomic, strong) NSString * streak;
@property (nonatomic, assign) NSUInteger totalPredictions;
@property (nonatomic, assign) NSUInteger alerts;
@property (nonatomic, assign) NSUInteger badges;
@property (nonatomic, assign) BOOL notificationsOn;

@property (nonatomic, strong) NSString* bigImage;
@property (nonatomic, strong) NSString* smallImage;
@property (nonatomic, strong) NSString* thumbImage;

@property (nonatomic, readonly) BOOL hasAvatar;

@property (nonatomic, assign) BOOL justSignedUp;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
