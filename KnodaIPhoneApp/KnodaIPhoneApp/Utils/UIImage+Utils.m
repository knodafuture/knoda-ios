//
//  UIImage+Utils.m
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 21.08.13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "UIImage+Utils.h"

@implementation UIImage (Utils)

- (UIImage *)scaledToSize:(CGSize)size; {
    
    UIGraphicsBeginImageContextWithOptions(size, NO, [[UIScreen mainScreen] scale]);
    
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
