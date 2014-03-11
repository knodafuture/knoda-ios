//
//  WebObject.h
//  KnodaIPhoneApp
//
//  Created by nick on 12/5/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle.h>

@interface WebObject : MTLModel <MTLJSONSerializing>


+ (id)instanceFromData:(NSData *)data;
+ (NSArray *)arrayFromData:(NSData *)data;

+ (NSValueTransformer *)remoteImageTransformer;
+ (NSValueTransformer *)challengeTransformer;
+ (NSValueTransformer *)boolTransformer;
+ (NSValueTransformer *)dateTransformer;
@end
