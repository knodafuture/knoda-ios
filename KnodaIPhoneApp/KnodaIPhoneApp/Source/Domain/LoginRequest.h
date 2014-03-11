//
//  LoginRequest.h
//  KnodaIPhoneApp
//
//  Created by nick on 12/5/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "WebObject.h"

@interface LoginRequest : WebObject
@property (strong, nonatomic) NSString *login;
@property (strong, nonatomic) NSString *password;
@end
