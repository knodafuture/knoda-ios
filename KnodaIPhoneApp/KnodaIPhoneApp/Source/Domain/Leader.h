//
//  Leader.h
//  KnodaIPhoneApp
//
//  Created by nick on 3/17/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "WebObject.h"
@class RemoteImage;
@interface Leader : WebObject
@property (strong, nonatomic) NSString *username;
@property (assign, nonatomic) NSInteger rank;
@property (strong, nonatomic) RemoteImage *avatar;
@property (assign, nonatomic) BOOL verifiedAccount;
@property (assign, nonatomic) NSInteger won;
@property (assign, nonatomic) NSInteger lost;
@end
