//
//  PasswordResetRequest.h
//  KnodaIPhoneApp
//
//  Created by nick on 3/11/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebObject.h"

@interface PasswordResetRequest : WebObject
@property (strong, nonatomic) NSString *login;
@end
