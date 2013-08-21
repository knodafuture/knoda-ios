//
//  BaseModelObject.h
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 16.08.13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const kSelfObserverKey;

@interface BaseModelObject : NSObject

@property (nonatomic, assign) BOOL doNotObserve;

- (void)updateWithObject:(BaseModelObject *)object;
- (void)replaceWithObject:(BaseModelObject *)object;

@end
