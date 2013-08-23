//
//  BadgesWebRequest.m
//  KnodaIPhoneApp
//
//  Created by Vyacheslav Nechiporenko on 8/19/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "BadgesWebRequest.h"

NSString* const NewBadgeNotification = @"NewBadgeNotification";
NSString* const kNewBadgeImages      = @"NewBadgeNotificationImages";

@interface BadgesWebRequest() {
    BOOL _forNew;
}

@end

@implementation BadgesWebRequest

+ (void)checkNewBadges {
    BadgesWebRequest *request = [BadgesWebRequest new];
    request->_forNew = YES;
    [request executeWithCompletionBlock:^{
        if(request.isSucceeded && request.badgesImagesArray.count) {
            NSDictionary *userInfo = @{kNewBadgeImages : request.badgesImagesArray};
            [[NSNotificationCenter defaultCenter] postNotificationName:NewBadgeNotification object:nil userInfo:userInfo];
        }
    }];
}

- (NSString*) methodName
{
    return _forNew ? @"badges/recent.json" : @"badges.json";
}

- (BOOL) requiresAuthToken
{
    return YES;
}

- (void) fillResultObject: (id) parsedResult
{
    if ([parsedResult respondsToSelector:@selector(valueForKey:)]) {
        self.badgesImagesArray = [[NSMutableArray alloc]init];
        [[parsedResult valueForKey:@"badges"]enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [self.badgesImagesArray addObject:[UIImage imageNamed:[obj valueForKey:@"name"]]];
        }];
    }
}

@end
