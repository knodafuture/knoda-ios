//
//  ImageCache.h
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 20.08.13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ImageBindable;

@interface ImageCache : NSObject

+ (instancetype)instance;

- (void)bindImage:(NSString *)imgURL toView:(UIView<ImageBindable> *)bindableView;
- (void)bindImage:(NSString *)imgURL toView:(UIView<ImageBindable> *)bindableView withCornerRadius:(CGFloat)radius;

- (void)clear;

@end
