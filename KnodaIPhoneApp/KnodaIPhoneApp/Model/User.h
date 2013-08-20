//
//  User.h
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/9/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "BaseModelObject.h"

@interface User : BaseModelObject

@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* email;
@property (nonatomic, strong) UIImage* profileImage;
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

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
