//
//  ContestStage.m
//  KnodaIPhoneApp
//
//  Created by nick on 8/1/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "ContestStage.h"

@implementation ContestStage
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"contestStageId" : @"id",
             @"name": @"name",
             @"contestId" : @"contest_id",
             @"sortOrder" : @"sort_order"
             };
}
@end
