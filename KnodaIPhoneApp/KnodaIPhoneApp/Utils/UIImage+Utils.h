//
//  UIImage+Utils.h
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 21.08.13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Utils)

- (UIImage *)scaledToSize:(CGSize)size;
- (UIImage *)roundedImageWithRadius:(CGFloat)radius;

@end
