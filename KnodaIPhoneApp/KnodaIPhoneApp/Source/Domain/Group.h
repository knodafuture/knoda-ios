//
//  Group.h
//  KnodaIPhoneApp
//
//  Created by nick on 3/17/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "WebObject.h"
#import "Leader.h"
#import "RemoteImage.h"

extern NSString *ActiveGroupChangedNotificationName;
extern NSString *ActiveGroupNotificationKey;

@class Member;
@interface Group : WebObject
@property (assign, nonatomic) NSInteger groupId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *groupDescription;
@property (strong, nonatomic) Leader *leader;
@property (assign, nonatomic) NSInteger rank;
@property (assign, nonatomic) NSInteger memberCount;
@property (strong, nonatomic) RemoteImage *avatar;
@property (assign, nonatomic) NSInteger owner;
@property (strong, nonatomic) NSString *shareUrl;
@property (strong, nonatomic) Member *myMembership;
@end
