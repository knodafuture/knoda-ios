//
//  BaseModelObject.m
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 16.08.13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "BaseModelObject.h"
#import "NSDate+Utils.h"
#import <objc/runtime.h>

NSString* const kSelfObserverKey = @"selfObserver";
static NSString* const kResponseDateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'zzz";

@interface BaseModelObject()

@end

@implementation BaseModelObject

@synthesize doNotObserve = doNotObserve;

+ (NSSet *)propertyKeys {
    NSMutableSet *keys = [NSMutableSet set];
    unsigned int count;
    
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    
    for (size_t i = 0; i < count; ++i) {
        [keys addObject:[NSString stringWithCString:property_getName(properties[i]) encoding:NSASCIIStringEncoding]];
    }
    free(properties);
    
    return keys;
}

- (void)updateWithObject:(BaseModelObject *)object {
    [self updateWithObject:object shouldReplaceWithNull:NO];
}

- (void)replaceWithObject:(BaseModelObject *)object {
    [self updateWithObject:object shouldReplaceWithNull:YES];
}

- (void)updateWithObject:(BaseModelObject *)object shouldReplaceWithNull:(BOOL)shouldReplace {
    if([object isMemberOfClass:[self class]]) {
        self.doNotObserve = YES;
        
        NSDictionary *dict = [object dictionaryWithValuesForKeys:[[[self class] propertyKeys] allObjects]];
        
        NSEnumerator *enumerator = [dict keyEnumerator];
        NSString *key;
        while ((key = [enumerator nextObject])) {
            if([key isEqualToString:@"doNotObserve"]||[key isEqualToString:@"justSignedUp"]) {
                continue;
            }
            id value = dict[key];
            if(shouldReplace || (value && ![value isKindOfClass:[NSNull class]])) {
                SEL selector = NSSelectorFromString([NSString stringWithFormat:@"set%@:", [key stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[key substringToIndex:1] uppercaseString]]]);
                if([self respondsToSelector:selector]) {
                    [self setValue:value forKey:key];
                }
            }
        };
        
        self.doNotObserve = NO;
    }
    else {
        DLog(@"Trying to update from wrong object!!! (%@)", object);
    }
}

- (NSString *)description {
    return [[self dictionaryWithValuesForKeys:[[[self class] propertyKeys] allObjects]] description];
    
}
- (NSDate *)dateFromObject:(id)obj {
    if (obj && ![obj isKindOfClass: [NSNull class]] && [obj isKindOfClass:[NSString class]]) {
        return [NSDate dateFromString:[obj stringByAppendingString: @"GMT"] withFormat:kResponseDateFormat];
    }
    return nil;
}
@end
