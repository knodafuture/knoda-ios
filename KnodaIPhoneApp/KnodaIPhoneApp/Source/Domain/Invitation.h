//
//  Invitation.h
//  KnodaIPhoneApp
//
//  Created by nick on 3/20/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebObject.h"   

@interface Invitation : WebObject
@property (assign, nonatomic) NSInteger groupId;
@property (assign, nonatomic) NSInteger userId;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *phoneNumber;


@end
