//
//  LoginWebRequest.h
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/12/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "BaseWebRequest.h"

@class User;

@interface LoginWebRequest : BaseWebRequest

@property (nonatomic, strong) User* user;

- (id) initWithUsername: (NSString*) userName password: (NSString*) password;

@end
