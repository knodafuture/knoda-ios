//
//  Contest.h
//  KnodaIPhoneApp
//
//  Created by nick on 8/1/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "WebObject.h"

@class RemoteImage;
@class ContestStage;
@class Leader;

@interface Contest : WebObject

@property (strong, nonatomic) NSNumber *contestId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *description;
@property (strong, nonatomic) NSString *detailsUrl;
@property (strong, nonatomic) RemoteImage *image;

@property (strong, nonatomic) NSArray *contestStages;
@property (strong, nonatomic) Leader *leader;

@property (strong, nonatomic) NSNumber *rank;
@property (strong, nonatomic) NSNumber *participants;
@property (strong, nonatomic) NSDictionary *myInfo;

@end
