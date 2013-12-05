//
//  UIColor+Utils.m
//  KnodaIPhoneApp
//
//  Created by Nick R on 11/7/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "UIColor+Utils.h"
#define UIColorFromRGB(rgbValue, alpha) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:alpha]

@implementation UIColor (Utils)


+ (UIColor *)colorFromHex:(NSString *)hexString {
	return [self colorFromHex:hexString withAlpha:1.0f];
}

+ (UIColor *)colorFromHex:(NSString*)hexString withAlpha:(float)alpha
{
	if (hexString == nil)
		return [UIColor blackColor];
    
	NSScanner *scanner = [NSScanner scannerWithString:hexString];
	unsigned hex;
	BOOL success = [scanner scanHexInt:&hex];
    
	return success ? UIColorFromRGB(hex, alpha) : [UIColor blackColor];
}

- (NSString *)hexString {
    const CGFloat *components = CGColorGetComponents(self.CGColor);
    
	CGFloat r,g,b;
    r = components[0];
    g = components[1];
    b = components[2];
    
	r = MIN(MAX(r, 0.0f), 1.0f);
	g = MIN(MAX(g, 0.0f), 1.0f);
	b = MIN(MAX(b, 0.0f), 1.0f);
    
	unsigned int rgb = (((int)roundf(r * 255)) << 16) | (((int)roundf(g * 255)) << 8) | (((int)roundf(b * 255)));
	return [NSString stringWithFormat:@"%0.6X", rgb];
}
@end
