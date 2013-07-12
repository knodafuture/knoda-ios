//
//  SugnUpRequest.h
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/12/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "BaseWebRequest.h"

@class User;

@interface SignUpRequest : BaseWebRequest

@property (nonatomic, strong) User* user;

- (id) initWithUsername: (NSString*) userName email: (NSString*) email password: (NSString*) password;

@end
