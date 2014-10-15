//
//  Alert.h
//  KnodaIPhoneApp
//
//  Created by nick on 12/11/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "WebObject.h"

typedef NS_ENUM(NSInteger, ActivityItemType) {
    ActivityTypeUnknown,
    ActivityTypeLost,
    ActivityTypeWon,
    ActivityTypeExpired,
    ActivityTypeComment,
    ActivityTypeInvitation,
    ActivityTypeFollow,
    ActivityItemTypeCommentMention,
    ActivityItemTypePredictionMention
};

@interface ActivityItem : WebObject
@property (assign, nonatomic) NSInteger activityItemId;
@property (strong, nonatomic) NSString *target;
@property (assign, nonatomic) ActivityItemType type;
@property (strong, nonatomic) NSDate *creationDate;
@property (strong, nonatomic) NSString *text;

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *body;
@property (strong, nonatomic) NSString *imageUrl;
@property (assign, nonatomic) BOOL shareable;

@property (assign, nonatomic) BOOL seen;
@end
