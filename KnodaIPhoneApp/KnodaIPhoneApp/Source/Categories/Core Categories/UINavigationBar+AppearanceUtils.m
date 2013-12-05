//
//  UINavigationBar+AppearanceUtils.m
//  KnodaIPhoneApp
//
//  Created by nick on 12/11/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "UINavigationBar+AppearanceUtils.h"

@implementation UINavigationBar (AppearanceUtils)
+ (void)setCustomAppearance {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"NavBar"] forBarMetrics:UIBarMetricsDefault];
    }
    else {
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"NavBar6"] forBarMetrics:UIBarMetricsDefault];
        
        [[UINavigationBar appearance] setTitleVerticalPositionAdjustment:4.0 forBarMetrics:UIBarMetricsDefault];        
    }
    
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor colorFromHex:@"235C37"], UITextAttributeTextColor,
                                                           [UIFont fontWithName: @"Krona One" size: 15], UITextAttributeFont,
                                                           [UIColor clearColor], UITextAttributeTextShadowColor ,nil]];

    [UINavigationItem setSpacerEnabled:YES];
}

+ (void)setDefaultAppearance {
    [[UINavigationBar appearance] setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTitleVerticalPositionAdjustment:0 forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:nil];
    
    [[UINavigationBar appearance] setTitleTextAttributes:nil];
    
    [UINavigationItem setSpacerEnabled:NO];
}
@end
