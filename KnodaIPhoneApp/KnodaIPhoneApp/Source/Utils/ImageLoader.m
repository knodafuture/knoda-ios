//
//  ImageLoader.m
//  KnodaIPhoneApp
//
//  Created by nick on 12/6/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "ImageLoader.h"
#import "WebApi.h"

@interface ImageLoader () {
	NSCache *_cache;
	NSMutableDictionary *_tableAssetsWaiting;
	NSMutableDictionary *_tableAssetsDownloading;
	NSMutableDictionary *_sectionAssetsDownloading;
}

@end

@implementation ImageLoader

@synthesize delegate = _delegate;
@synthesize tableView = _tableView;

- (id)initForTable:(UITableView *)tableView delegate:(id<ImageLoaderDelegate>)delegate {
	self = [super init];
	_delegate = delegate;
	_cache = [[NSCache alloc] init];
	_tableView = tableView;
	_tableAssetsWaiting = [[NSMutableDictionary alloc] init];
	_tableAssetsDownloading = [[NSMutableDictionary alloc] init];
	return self;
}

- (UIImage *)lazyLoadImage:(NSString *)imageUrl onIndexPath:(NSIndexPath *)indexPath {
    
    if (!imageUrl)
        return nil;

	UIImage *image = [_cache objectForKey:imageUrl];
	
	if (!image) {
		if (_tableView.dragging || _tableView.decelerating)
			[self registerForLoadingImage:imageUrl onIndexPath:indexPath];
		else
			[self fetchImage:imageUrl onIndexPath:indexPath];
	}
	
	return image;
}

- (void)registerForLoadingImage:(NSString *)imageUrl onIndexPath:(NSIndexPath *)indexPath {
    [_tableAssetsWaiting setObject:imageUrl forKey:indexPath];
}

- (void)fetchImage:(NSString *)imageUrl onIndexPath:(NSIndexPath *)indexPath {
	if ([_tableAssetsDownloading objectForKey:indexPath])
		return;
	
	[_tableAssetsDownloading setObject:imageUrl forKey:indexPath];
    
    [[WebApi sharedInstance] getImage:imageUrl completion:^(UIImage *image, NSError *error) {
        
        if (error) {
            NSLog(@"Error loading image %@", imageUrl);
            return;
        }
        
        if (image) {
            
            if ([self.delegate respondsToSelector:@selector(imageLoader:willCacheImage:forIndexPath:)]) {
                image = [self.delegate imageLoader:self willCacheImage:image forIndexPath:indexPath];
            }
            
            [_cache setObject:image forKey:imageUrl];
        }
        
        [_tableAssetsDownloading removeObjectForKey:indexPath];
        [_tableAssetsWaiting removeObjectForKey:indexPath];
        [self _image:image finishedLoadingForIndexPath:indexPath];
        
    }];
}

- (void)_image:(UIImage *)image finishedLoadingForIndexPath:(NSIndexPath *)indexPath {
	if ([[_tableView indexPathsForVisibleRows] containsObject:indexPath] || indexPath.row == INT_MAX)
		[_delegate imageLoader:self finishedLoadingImage:image forIndexPath:indexPath];
}

- (void)loadVisibleAssets {
	NSArray *visiblePaths = [_tableView indexPathsForVisibleRows];
	for (NSIndexPath *indexPath in visiblePaths) {
		NSString *imageUrl = [_tableAssetsWaiting objectForKey:indexPath];
		if (imageUrl)
			[self fetchImage:imageUrl onIndexPath:indexPath];
	}
}
@end
