//
//  Leader.m
//  KnodaIPhoneApp
//
//  Created by nick on 3/17/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "Leader.h"

@implementation Leader
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"avatar": @"avatar_image"
             };
}


+ (NSValueTransformer *)avatarJSONTransformer {
    return [self remoteImageTransformer];
}
@end
