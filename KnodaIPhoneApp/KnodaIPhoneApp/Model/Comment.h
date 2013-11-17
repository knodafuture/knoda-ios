//
//  Comment.h
//  KnodaIPhoneApp
//
//  Created by Nick R on 11/17/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "BaseModelObject.h"

@class Challenge;
@interface Comment : BaseModelObject

@property (assign, nonatomic) NSInteger _id;
@property (assign, nonatomic) NSInteger userId;
@property (strong, nonatomic) NSString *username;
@property (assign, nonatomic) NSInteger predictionId;
@property (strong, nonatomic) NSString *body;
@property (strong, nonatomic) NSDate *createdDate;
@property (strong, nonatomic) Challenge *challenge;

@property (strong, nonatomic) NSString *bigUserImage;
@property (strong, nonatomic) NSString *smallUserImage;
@property (strong, nonatomic) NSString *thumbUserImage;

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (NSString *)createdAtString;
@end
