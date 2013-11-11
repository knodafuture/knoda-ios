//
//  ImageEntry.m
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 20.08.13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "ImageEntry.h"
#import "NSString+Utils.h"
#import "BaseWebRequest.h"
#import "UIImage+Utils.h"

static const int kMaxFileNameLength = 254;

@interface ImageEntry() {
    CGFloat _cornerRadius;
}

@property (atomic, assign) BOOL isLoading;

@end

@implementation ImageEntry

#pragma mark Public

- (id)initWithURL:(NSString *)imgURL {
    if(self = [super init]) {
        _imgUrl = imgURL;
    }
    return self;
}

- (void)loadImageWithCornerRadius:(CGFloat)radius completion:(ImageLoadCompletionBlock)completion {
    
    //DLog(@"obtaining image for URL : %@", self.imgUrl);
    
    assert(completion);
    
    self.isLoading = YES;
    
    _cornerRadius = radius;
    
    ImageLoadCompletionBlock block = [completion copy];
    
    if(!self.image) {
        [self loadFromStorage];
        if(!self.image) {
            [self loadFromServer];
        }
    }
    else {
        //DLog(@"found image in memory %@", self.imgUrl);
    }
    
    block();
    
    self.isLoading = NO;
}

- (void)unload {
    _image = nil;
    _creationDate = nil;
}

- (void)clear {
    _image = nil;
    _creationDate = nil;
    
    NSString *fileName = [self getFileName];
    if([[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:fileName error:&error];
        if(error) {
            DLog(@"%@", error);
        }
    }
}

#pragma mark Private

- (void)loadFromStorage {
    
    NSString *fileName = [self getFileName];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
        //DLog(@"found img (%@) at storage", self.imgUrl);
        _image = [UIImage imageWithContentsOfFile:[self getFileName]];
        if(_image) {
            [self setupCreationDate:fileName];
        }
    }
}

- (void)loadFromServer {
    //DLog(@"downloading img from %@", [self getImageURL]);
    NSError *error = nil;
    NSData *imgData = [NSData dataWithContentsOfURL:[self getImageURL] options:0 error:&error];
    NSLog(@"IMAGE URL: %@", [self getImageURL]);
    _error = error;
    if(!error && imgData) {
        _image = [UIImage imageWithData:imgData];        
        
        [self writeImage];
    }
    else {
        _image = nil;
        DLog(@"failed to load image: %@", error);
    }
}

- (void)writeImage {
    if(_image) {
        //DLog(@"write img to file: %@", self.imgUrl);
        NSData *dataImg = UIImagePNGRepresentation(_image);
        NSError *error = nil;
        
        NSString *fileName = [self getFileName];
        
        [dataImg writeToFile:fileName options:NSDataWritingAtomic error:&error];
        _error = error;
        if(!error) {
            [self setupCreationDate:fileName];
        }
    }
}

- (NSURL *)getImageURL {
    if ([self.imgUrl rangeOfString:@"http"].location == NSNotFound)
    {
        return [NSURL URLWithString:[NSString stringWithFormat:@"http://%@%@", kBaseURL, self.imgUrl]];
    }
    else
    {
        return [NSURL URLWithString:self.imgUrl];
    }

}

+ (NSString *)cachePath {
    static NSString *_cachePath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        _cachePath = [_cachePath stringByAppendingPathComponent:@"images"];
        if(![[NSFileManager defaultManager] fileExistsAtPath:_cachePath]) {
            NSError *error = nil;
            if(![[NSFileManager defaultManager] createDirectoryAtPath:_cachePath withIntermediateDirectories:NO attributes:nil error:&error]) {
                DLog(@"cannot create cache directory for images (%@)", error);
            }
        }
    });
    return _cachePath;
}

- (NSString *)getFileName {
    NSString* path = [[[self class] cachePath] stringByAppendingPathComponent:[self.imgUrl safeFileName]];
    return path.length > kMaxFileNameLength ? [path substringToIndex:kMaxFileNameLength] : path;
}

- (void)setupCreationDate:(NSString *)fileName {
    NSError *error = nil;
    NSDictionary *attr = [[NSFileManager defaultManager] attributesOfItemAtPath:fileName error:&error];
    if(!error) {
        _creationDate = (NSDate *)attr[NSFileCreationDate];
    }
    else {
        DLog(@"%@", error);
    }
}

@end
