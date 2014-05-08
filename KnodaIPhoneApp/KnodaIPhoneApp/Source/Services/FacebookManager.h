//
//  FacebookManager.h
//  KnodaIPhoneApp
//
//  Created by nick on 4/28/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FacebookManager : NSObject

+ (FacebookManager *)sharedInstance;

- (void)handleAppLaunch;

- (void)openSession:(void(^)(NSDictionary *data, NSError *error))completionHandler;
- (NSString *)accessTokenForCurrentSession;

@end
