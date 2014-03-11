//
//  NewUser.h
//  KnodaIPhoneApp
//
//  Created by nick on 12/5/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "WebObject.h"
#import "RemoteImage.h"

@interface User : WebObject

@property (assign, nonatomic) NSInteger userId;
@property (assign, nonatomic) NSUInteger points;
@property (assign, nonatomic) NSUInteger won;
@property (assign, nonatomic) NSUInteger lost;
@property (assign, nonatomic) NSUInteger totalPredictions;

@property (strong, nonatomic) NSNumber *winningPercentage;
@property (strong, nonatomic) NSString *streak;

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *email;

@property (strong, nonatomic) RemoteImage *avatar;
@property (assign, nonatomic) BOOL verifiedAccount;

@end
