//
//  ChangePasswordRequest.h
//  KnodaIPhoneApp
//
//  Created by Vyacheslav Nechiporenko on 8/21/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "BaseWebRequest.h"

@interface ChangePasswordRequest : BaseWebRequest

- (id) initWithCurrentPassword : (NSString*) surrentPassword newPassword : (NSString *) newPassword;

@end
