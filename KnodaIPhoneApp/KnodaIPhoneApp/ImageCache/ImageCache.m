//
//  ImageCache.m
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 20.08.13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "ImageCache.h"
#import "ImageEntry.h"

#import "ImageBindable.h"

static const int kMaxSimultaneousLoading = 10;

@interface ImageCache()

@property (atomic) NSMutableArray *imageEntries;
@property (atomic) NSMapTable *views;
@property (atomic) NSUInteger loadingsCount;

@end

@implementation ImageCache

+ (instancetype)instance {
    static ImageCache *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [ImageCache new];
    });
    return _instance;
}

- (id)init {
    if(self = [super init]) {
        self.imageEntries = [NSMutableArray array];
        self.views = [NSMapTable weakToStrongObjectsMapTable];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMemoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

- (void)handleMemoryWarning {
    DLog(@"");
    [self.imageEntries makeObjectsPerformSelector:@selector(unload)];
}

- (void)clear {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self.imageEntries makeObjectsPerformSelector:@selector(unload)];
        
        NSError *error      = nil;
        NSFileManager *fm   = [NSFileManager defaultManager];
        NSString *cachePath = [ImageEntry cachePath];
        NSArray *images     = [fm contentsOfDirectoryAtPath:cachePath error:&error];
        if(error) {
            DLog(@"cannot clear cached images (%@)", error);
            return;
        }
        for(NSString *imageFile in images) {
            NSString *filePath = [cachePath stringByAppendingPathComponent:imageFile];
            if(![fm removeItemAtPath:filePath error:&error]) {
                DLog(@"cannot remove image at path: %@ Error: %@", filePath, error);
            }
        }
        DLog(@"cached images were cleared");
    });
}

- (void)bindImage:(NSString *)imgURL toView:(UIView<ImageBindable>*)bindableView creationData:(NSDate *)creationDate cornerRadius:(CGFloat)radius {
    
    //DLog(@"bind image %@", imgURL);
    
    __weak UIView<ImageBindable> *view = bindableView;
    
    if(!view) {
        return;
    }
    
    if(!imgURL.length) {
        //DLog(@"img url is null");
        [view didLoadImage:nil error:nil];
        return;
    }
    
    [view didStartImageLoading];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        ImageEntry *entry = [[self.imageEntries filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"imgUrl == %@", imgURL]] lastObject];
        if(!entry) {
            entry = [[ImageEntry alloc] initWithURL:imgURL];
            [self.imageEntries addObject:entry];
        }
        
        if(!entry.isLoading && self.loadingsCount < kMaxSimultaneousLoading) {
            self.loadingsCount++;
            [entry loadImageWithCornerRadius:radius completion:^{
                if(entry.error) {
                    DLog(@"%@", entry.error);
                }
                if(view) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [view didLoadImage:entry.image error:entry.error];
                        [self.views removeObjectForKey:view];
                        [self bindNext];
                    });
                }
                if(creationDate) { //check if the cached entry is up to date
                    if([creationDate timeIntervalSinceDate:entry.creationDate] > 0) {
                        [entry clear];
                        [self bindImage:imgURL toView:view];
                    }
                }
                self.loadingsCount--;
            }];
        }
        else {
            [self.views setObject:imgURL forKey:view];
        }
    });
}

- (void)bindImage:(NSString *)imgURL toView:(UIView<ImageBindable> *)bindableView {
    [self bindImage:imgURL toView:bindableView creationData:nil cornerRadius:0.0];
}

- (void)bindImage:(NSString *)imgURL toView:(UIView<ImageBindable> *)bindableView withCornerRadius:(CGFloat)radius {
    [self bindImage:imgURL toView:bindableView creationData:nil cornerRadius:radius];
}

- (void)bindNext {
    if(self.views.count) {
        UIView<ImageBindable> *view = [[self.views keyEnumerator] nextObject];
        [self bindImage:[self.views objectForKey:view] toView:view];
    }
}

@end

