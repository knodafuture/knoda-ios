//
//  UIBarButtonItem+Utils.h
//  KnodaIPhoneApp
//
//  Created by Nick R on 11/10/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (Utils)
+ (UIBarButtonItem *)backButtonWithTarget:(id)target action:(SEL)action;
+ (UIBarButtonItem *)disabledBarButtonItemWithTitle:(NSString *)title color:(UIColor *)color;
+ (UIBarButtonItem *)styledBarButtonItemWithTitle:(NSString *)title target:(id)target action:(SEL)action color:(UIColor *)color;
+ (UIBarButtonItem *)leftBarButtonItemWithImage:(UIImage *)image target:(id)target action:(SEL)action;
+ (UIBarButtonItem *)rightBarButtonItemWithImage:(UIImage *)image target:(id)target action:(SEL)action;
+ (UIBarButtonItem *)sideNavBarBUttonItemwithTarget:(id)target action:(SEL)action;
@end
