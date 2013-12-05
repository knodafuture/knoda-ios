//
//  Alert.h
//  KnodaIPhoneApp
//
//  Created by nick on 12/11/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "WebObject.h"

typedef NS_ENUM(NSInteger, AlertType) {
    AlertTypeUnknown,
    AlertTypeLost,
    AlertTypeWon,
    AlertTypeExpired,
    AlertTypeComment
};


@interface Alert : WebObject
@property (assign, nonatomic) NSInteger alertId;
@property (assign, nonatomic) NSInteger predictionId;
@property (assign, nonatomic) NSInteger userId;
@property (assign, nonatomic) AlertType alertType;
@property (assign, nonatomic) BOOL seen;
@property (strong, nonatomic) NSDate *creationDate;
@property (readonly, nonatomic) NSString *createdAtString;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *predictionBody;

- (UIImage *)image;
@end
