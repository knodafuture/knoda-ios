//
//  SendDeviceTokenWebRequest.h
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 8/27/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "BaseWebRequest.h"

@interface SendDeviceTokenWebRequest : BaseWebRequest

@property (nonatomic, strong) NSNumber* tokenID;

- (id) initWithToken: (NSString*) token;

@end
