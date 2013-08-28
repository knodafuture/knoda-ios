//
//  ProfileWebRequest.h
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 19.08.13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "BaseWebRequest.h"

@class User;

@interface ProfileWebRequest : BaseWebRequest

@property (nonatomic, readonly) User *user;

- (id)initWithAvatar:(UIImage *)avatarImage;
- (id)initWithNewUsername:(NSString *)username;
- (id)initWithNewEmail:(NSString *)email;

@end
