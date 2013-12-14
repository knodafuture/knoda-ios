//
//  FileCache.m
//  KnodaIPhoneApp
//
//  Created by nick on 12/6/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "FileCache.h"
#import "NSString+Utils.h"

NSString *const FileCacheDefaultGroup = @"FileCacheDefaultGroup";

NSString *const TimeoutsUserDefaultsKey	= @"FileCacheTimeouts";
NSString *const TimestampsUserDefaultsKey	= @"FileCacheTimestamps";

@interface FileCache ()

@property (strong, nonatomic) NSMutableDictionary *timestamps;
@property (strong, nonatomic) NSMutableDictionary *timeouts;
@property (strong, nonatomic) NSString *cacheDirectory;
@property (strong, nonatomic) dispatch_queue_t dispatchQueue;

@end

@implementation FileCache

- (id)init {
	self = [super init];
	if (self) {
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *path = [paths objectAtIndex:0];
		self.cacheDirectory = [path stringByAppendingPathComponent:@"/Library/Caches"];
        [self createDirectory:self.cacheDirectory];
		self.dispatchQueue = dispatch_queue_create("FileCacheQueue", nil);
        
		[self initializeTimestamps];
		[self initializeTimeouts];
	}
	return self;
}

- (void)initializeTimestamps {
	NSDictionary *savedTimestamps = [[NSUserDefaults standardUserDefaults] valueForKey:TimestampsUserDefaultsKey];
	if (savedTimestamps)
		self.timestamps = [NSMutableDictionary dictionaryWithDictionary:savedTimestamps];
	else
		self.timestamps = [[NSMutableDictionary alloc] init];
}

- (void)initializeTimeouts {
	NSDictionary *savedTimeouts = [[NSUserDefaults standardUserDefaults] valueForKey:TimeoutsUserDefaultsKey];
	if (savedTimeouts)
		self.timeouts = [NSMutableDictionary dictionaryWithDictionary:savedTimeouts];
	else
		self.timeouts = [[NSMutableDictionary alloc] init];
}

- (void)createDirectory:(NSString *)directory {
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL isDirectory;
    if ([manager fileExistsAtPath:directory isDirectory:&isDirectory]) {
        if (!isDirectory) {
            NSLog(@"Directory [%@] exists as a file, deleting file and creating directory", directory);
            [manager removeItemAtPath:directory error:nil];
            [manager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    else {
        NSLog(@"Directory [%@] not found, creating", directory);
        [manager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];
    }
}


- (void)setData:(NSData *)data key:(NSString *)key timeout:(NSTimeInterval)timeout {
	if (!data || !key || !data.length)
		return;

	dispatch_async(self.dispatchQueue, ^{
        NSString *hash = [key md5Hash];
		NSString *fileName = [self.cacheDirectory stringByAppendingPathComponent:hash];
		NSError *error;
		[data writeToFile:fileName options:NSDataWritingAtomic error:&error];
		if (error) {
			NSLog(@"FileCache: error writing data to [%@] - %@", fileName, [error description]);
		}
		else {
			[self setTimeout:timeout forKey:hash];
			[self setTimestampForKey:hash];
		}
	});
}

- (void)dataForKey:(NSString *)key complete:(void(^)(NSData *data, BOOL stale))completionBlock {
	dispatch_async(_dispatchQueue, ^{
        NSString *hash = [key md5Hash];
		NSFileManager *manager = [NSFileManager defaultManager];
		NSString *fileName = [_cacheDirectory stringByAppendingPathComponent:hash];
		
		NSData *data = [manager contentsAtPath:fileName];
		BOOL stale = [self keyStale:hash];
        
		dispatch_async(dispatch_get_main_queue(), ^{
			completionBlock(data, stale);
		});
	});
}

- (void)setTimestampForKey:(NSString *)key {
	[self.timestamps setObject:[NSNumber numberWithInt:[[NSDate date] timeIntervalSince1970]] forKey:key];
	[[NSUserDefaults standardUserDefaults] setValue:self.timestamps forKey:TimestampsUserDefaultsKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setTimeout:(NSTimeInterval)timeout forKey:(NSString *)key {
	[self.timeouts setObject:[NSNumber numberWithDouble:timeout] forKey:key];
	[[NSUserDefaults standardUserDefaults] setValue:self.timeouts forKey:TimeoutsUserDefaultsKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)keyStale:(NSString *)key {
	NSNumber *timestamp = [_timestamps objectForKey:key];
	NSNumber *timeout = [_timeouts objectForKey:key];
	NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    
	if (!timeout || !timestamp)
		return YES;
	
	if ([timeout doubleValue] == FileCacheTimeInfinite)
		return NO;
    
	if (currentTime - [timestamp doubleValue] > [timeout doubleValue])
		return YES;
    
	return NO;
}

- (void)purge {
	[self recursiveClear:self.cacheDirectory];
}

- (void)recursiveClear:(NSString *)directory {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *files = [manager contentsOfDirectoryAtPath:directory error:nil];
    for (NSString *file in files) {
        NSString *filePath = [directory stringByAppendingPathComponent:file];
        BOOL isDirectory = NO;
        [manager fileExistsAtPath:filePath isDirectory:&isDirectory];
        if (isDirectory)
            [self recursiveClear:filePath];
        [manager removeItemAtPath:filePath error:nil];
    }
}

@end