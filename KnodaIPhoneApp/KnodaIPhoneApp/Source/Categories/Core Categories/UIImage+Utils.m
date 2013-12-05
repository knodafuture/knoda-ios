//
//  UIImage+Utils.m
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 21.08.13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "UIImage+Utils.h"

@implementation UIImage (Utils)

- (UIImage *)scaledToSize:(CGSize)size autoScale:(BOOL)scale; {
    
    float w = self.size.width;
    float h = self.size.height;
    
    float ratio = w < h ? size.width / w : size.height / h;
    
    CGRect rect = CGRectMake(0, 0, w * ratio, h * ratio);
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, scale ? [[UIScreen mainScreen] scale] : 1.0);
    
    [self drawInRect:rect];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (UIImage *)roundedImageWithRadius:(CGFloat)radius {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    
    CGPathRef clippingPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius].CGPath;
    CGContextAddPath(context, clippingPath);
    CGContextClip(context);
    
    [self drawInRect:rect];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
