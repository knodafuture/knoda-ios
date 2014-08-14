//
//  ContestStage.h
//  KnodaIPhoneApp
//
//  Created by nick on 8/1/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "WebObject.h"

@interface ContestStage : WebObject

@property (strong, nonatomic) NSNumber *contestStageId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSNumber *contestId;
@property (strong, nonatomic) NSNumber *sortOrder;

@end
