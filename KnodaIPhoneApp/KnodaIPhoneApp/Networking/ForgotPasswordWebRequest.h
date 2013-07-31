//
//  ForgotPasswordWebRequest.h
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/26/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "BaseWebRequest.h"

@interface ForgotPasswordWebRequest : BaseWebRequest

- (id) initWithEmail: (NSString*) email;

@end
