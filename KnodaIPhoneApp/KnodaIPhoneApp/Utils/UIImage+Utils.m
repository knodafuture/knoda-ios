//
//  UIImage+Utils.m
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 21.08.13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "UIImage+Utils.h"

@implementation UIImage (Utils)

- (UIImage *)scaledCroppedToSize:(CGSize)size; {
    float w = self.size.width;
    float h = self.size.height;
    
    float scaleFactor = (w < h) ? size.width / w : size.height / h;
    
    CGSize newSize = CGSizeMake(fminf(w * scaleFactor, size.width), fminf(h * scaleFactor, size.height));

    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(newSize, NO, [[UIScreen mainScreen] scale]);
    }
    else {
        UIGraphicsBeginImageContext(newSize);
    }
    
    [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
