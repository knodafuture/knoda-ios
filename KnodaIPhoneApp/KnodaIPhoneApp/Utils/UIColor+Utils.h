//
//  UIColor+Utils.h
//  KnodaIPhoneApp
//
//  Created by Nick R on 11/7/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Utils)
+ (UIColor *)colorFromHex:(NSString*)hexString;
+ (UIColor *)colorFromHex:(NSString*)hexString withAlpha:(float)alpha;
- (NSString *)hexString;
@end
