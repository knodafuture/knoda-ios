//
//  UIBarButtonItem+Utils.m
//  KnodaIPhoneApp
//
//  Created by Nick R on 11/10/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "UIBarButtonItem+Utils.h"
#import "AppDelegate.h"

#define PADDING 10.0
static UIFont *font = nil;

@implementation UIBarButtonItem (Utils)

+ (UIBarButtonItem *)backButtonWithTarget:(id)target action:(SEL)action {
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 20)];
    [backButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [backButton setImage:[UIImage imageNamed:@"BackIcon"] forState:UIControlStateNormal];
    return [[UIBarButtonItem alloc] initWithCustomView:backButton];
}

+ (UIBarButtonItem *)disabledBarButtonItemWithTitle:(NSString *)title color:(UIColor *)color {
    UILabel *label = [[UILabel alloc] init];
    [label setBackgroundColor:[UIColor clearColor]];
    [self setButtonFrame:label forTitle:title];
    [self setLabelAttributes:label forTitle:title andColor:color];
    return [[UIBarButtonItem alloc] initWithCustomView:label];
}

+ (UIBarButtonItem *)styledBarButtonItemWithTitle:(NSString *)title target:(id)target action:(SEL)action color:(UIColor *)color {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self setButtonFrame:button forTitle:title];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:color forState:UIControlStateNormal];
    [self setLabelAttributes:button.titleLabel forTitle:title andColor:color];
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

+ (void)setButtonFrame:(UIView *)view forTitle:(NSString *)title {
    CGSize size = [title sizeWithFont:[self getFont]];
    view.frame = CGRectMake(0, 0, size.width + 2*PADDING, 31.0);
}

+ (void)setLabelAttributes:(UILabel *)label forTitle:(NSString *)title andColor:(UIColor *)color {
    label.text = title;
    label.font = [self getFont];
    label.textColor = color;
    label.textAlignment = NSTextAlignmentCenter;
}

+ (UIFont *)getFont {
    if (!font)
        font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0];
    return font;
}

+ (UIBarButtonItem *)leftBarButtonItemWithImage:(UIImage *)image target:(id)target action:(SEL)action {
	UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, image.size.width * 2, image.size.height)];
	[button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [button setImage:image forState:UIControlStateHighlighted];
    [button setImage:image forState:UIControlStateNormal];
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, -image.size.width/4.0, 0, +image.size.width/4.0)];
	return [[UIBarButtonItem alloc] initWithCustomView:button];
}

+ (UIBarButtonItem *)rightBarButtonItemWithImage:(UIImage *)image target:(id)target action:(SEL)action {
	UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, image.size.width * 2, image.size.height)];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [button setImage:image forState:UIControlStateHighlighted];
    [button setImage:image forState:UIControlStateNormal];
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, image.size.width/2.0 + 3.0, 0, 0)];
	return [[UIBarButtonItem alloc] initWithCustomView:button];
}

+ (UIBarButtonItem *)addPredictionBarButtonItemWithTarget:(id)target action:(SEL)action {
    return [UIBarButtonItem rightBarButtonItemWithImage:[UIImage imageNamed:@"PredictIcon"] target:target action:action];
    
}

+ (UIBarButtonItem *)searchBarButtonItemWithTarget:(id)target action:(SEL)action {
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:target action:action];
}

@end
