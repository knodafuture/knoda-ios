//
//  Cache.h
//  KnodaIPhoneApp
//
//  Created by nick on 12/7/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, FileCacheTime) {
	FileCacheTimeInfinite			= INT_MAX,
	FileCacheTimeOneDay             = 86400,
	FileCacheTimeHalfDay			= 43200,
	FileCacheTimeOneHour			= 3600,
	FileCacheTimeHalfMinute         = 30
};

@protocol Cache <NSObject>

- (void)setData:(NSData *)data key:(NSString *)key timeout:(NSTimeInterval)timeout;
- (void)dataForKey:(NSString *)key complete:(void(^)(NSData *data, BOOL stale))completionBlock;
- (void)purge;

@end
