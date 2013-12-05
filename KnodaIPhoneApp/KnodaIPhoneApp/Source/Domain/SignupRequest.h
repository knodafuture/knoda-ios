//
//  SignupRequest.h
//  KnodaIPhoneApp
//
//  Created by nick on 12/5/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "WebObject.h"

@interface SignupRequest : WebObject

@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;

@end
