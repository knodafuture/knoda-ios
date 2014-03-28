//
//  InvitationCodeDetails.h
//  KnodaIPhoneApp
//
//  Created by nick on 3/27/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "WebObject.h"
@class Group;
@interface InvitationCodeDetails : WebObject
@property (assign, nonatomic) NSNumber *invitationId;
@property (strong, nonatomic) NSString *link;
@property (strong, nonatomic) Group *group;
@end
