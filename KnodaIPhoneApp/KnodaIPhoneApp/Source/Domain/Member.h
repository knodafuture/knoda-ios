//
//  Member.h
//  KnodaIPhoneApp
//
//  Created by nick on 3/19/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "WebObject.h"
typedef NS_ENUM(NSInteger, MembershipType) {
    MembershipTypeUnknown,
    MembershipTypeMember,
    MembershipTypeOwner
};


@interface Member : WebObject
@property (assign, nonatomic) NSInteger memberId;
@property (assign, nonatomic) MembershipType role;
@property (strong, nonatomic) NSString *username;
@property (assign, nonatomic) NSInteger groupId;
@property (assign, nonatomic) NSInteger userId;
@end
