//
//  UIView+Test.m
//  KnodaIPhoneApp
//
//  Created by nick on 7/17/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "UIView+Utils.h"

@implementation UIView (Utils)

- (UIImage *)captureView {
    UIGraphicsBeginImageContext(self.bounds.size);
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
        [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
    else {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, [UIScreen mainScreen].scale );
        CGContextRef context = UIGraphicsGetCurrentContext();
        [self.layer renderInContext:context];
   }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
@end
