//
//  NavigationScrollView.m
//  KnodaIPhoneApp
//
//  Created by nick on 12/13/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "NavigationScrollView.h"

@implementation NavigationScrollView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	if (self.disabled)
		self.scrollEnabled = NO;
	else {
		CGPoint adjustedPoint = CGPointMake(point.x - self.contentOffset.x, point.y - self.contentOffset.y);
		self.scrollEnabled = adjustedPoint.x < self.bezelWidth;
	}
	
	return [super hitTest:point withEvent:event];
}

@end
