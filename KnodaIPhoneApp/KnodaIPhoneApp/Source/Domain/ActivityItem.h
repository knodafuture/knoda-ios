//
//  Alert.h
//  KnodaIPhoneApp
//
//  Created by nick on 12/11/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "WebObject.h"

typedef NS_ENUM(NSInteger, ActivityItemType) {
    AlertTypeUnknown,
    AlertTypeLost,
    AlertTypeWon,
    AlertTypeExpired,
    AlertTypeComment
};

@interface ActivityItem : WebObject
@property (assign, nonatomic) NSInteger activityItemId;
@property (assign, nonatomic) NSInteger predictionId;
@property (assign, nonatomic) NSInteger userId;
@property (assign, nonatomic) ActivityItemType alertType;
@property (assign, nonatomic) BOOL seen;
@property (strong, nonatomic) NSDate *creationDate;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *predictionBody;

@end
