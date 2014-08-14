//
//  UIView+Test.m
//  KnodaIPhoneApp
//
//  Created by nick on 7/17/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "UIView+Utils.h"

@implementation UIView (Utils)

- (void)findScrollViews {
    if ([self respondsToSelector:@selector(scrollsToTop)]) {
        NSLog(@"-------");
        NSLog(@"I scroll to top - %@", NSStringFromClass(self.class));
        NSLog(@"My superview - %@", NSStringFromClass(self.superview.class));
        NSLog(@"Scroll to top = %i", [(id)self scrollsToTop]);
        if ([self respondsToSelector:@selector(delegate)])
            NSLog(@"My Delegate - %@", NSStringFromClass([(id)[(id)self delegate] class]));
        NSLog(@"-------");
    }
    
    for (UIView *subview in self.subviews) {
        [subview findScrollViews];
    }
}

- (UIImage *)captureView {
    UIGraphicsBeginImageContext(self.bounds.size);
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    return image;
}
@end
