//
//  AnotherUserProfileWebRequest.h
//  KnodaIPhoneApp
//
//  Created by Vyacheslav Nechiporenko on 8/22/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "BaseWebRequest.h"
#import "User.h"

@interface AnotherUserProfileWebRequest : BaseWebRequest

@property (nonatomic, strong) User * user;

- (id)initWithUserId:(NSInteger)userId;

@end
