//
//  ImageLoader.h
//  KnodaIPhoneApp
//
//  Created by nick on 12/6/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ImageLoader;

@protocol ImageLoaderDelegate <NSObject>

- (void)imageLoader:(ImageLoader *)loader finishedLoadingImage:(UIImage *)image forIndexPath:(NSIndexPath *)indexPath;

@end

@interface ImageLoader : NSObject

@property (weak, nonatomic) id<ImageLoaderDelegate> delegate;
@property (weak, nonatomic) UITableView *tableView;

- (id)initForTable:(UITableView *)tableView delegate:(id<ImageLoaderDelegate>)delegate;

- (UIImage *)lazyLoadImage:(NSString *)imageUrl onIndexPath:(NSIndexPath *)indexPath;
- (void)loadVisibleAssets;

@end
