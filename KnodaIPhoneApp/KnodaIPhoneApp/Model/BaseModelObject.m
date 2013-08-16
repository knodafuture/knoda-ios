//
//  BaseModelObject.m
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 16.08.13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "BaseModelObject.h"

#import <objc/runtime.h>

NSString* const kSelfObserverKey = @"selfObserver";

@interface BaseModelObject()

@end

@implementation BaseModelObject

@synthesize doNotObserve = doNotObserve;

+ (NSSet *)propertyKeys {
    
    static NSMutableSet *keys = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        keys = [NSMutableSet set];
        unsigned int count;
        
        objc_property_t *properties = class_copyPropertyList([self class], &count);
        
        for (size_t i = 0; i < count; ++i) {
            [keys addObject:[NSString stringWithCString:property_getName(properties[i]) encoding:NSASCIIStringEncoding]];
        }
        free(properties);
    });
    return keys;
}

- (void)updateWithObject:(BaseModelObject *)object {
    if([object isMemberOfClass:[self class]]) {
        self.doNotObserve = YES;
        
        NSDictionary *dict = [object dictionaryWithValuesForKeys:[[[self class] propertyKeys] allObjects]];
        [self setValuesForKeysWithDictionary:dict];
        
        self.doNotObserve = NO;
    }
    else {
        DLog(@"Trying to update from wrong object!!! (%@)", object);
    }
}

@end
