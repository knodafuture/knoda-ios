//
//  PasswordChangeRequest.h
//  KnodaIPhoneApp
//
//  Created by nick on 3/11/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "WebObject.h"

@interface PasswordChangeRequest : WebObject
@property (strong, nonatomic) NSString *currentPassword;
@property (strong, nonatomic) NSString *password;
@end
