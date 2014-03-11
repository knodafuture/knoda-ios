//
//  Comment.h
//  KnodaIPhoneApp
//
//  Created by Nick R on 11/17/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "WebObject.h"

@class Challenge;
@class RemoteImage;

@interface Comment : WebObject

@property (assign, nonatomic) NSInteger commentId;
@property (assign, nonatomic) NSInteger userId;
@property (strong, nonatomic) NSString *username;
@property (assign, nonatomic) NSInteger predictionId;
@property (strong, nonatomic) NSString *body;
@property (strong, nonatomic) NSDate *creationDate;
@property (strong, nonatomic) Challenge *challenge;
@property (strong, nonatomic) RemoteImage *userAvatar;
@property (assign, nonatomic) BOOL verifiedAccount;
@end
