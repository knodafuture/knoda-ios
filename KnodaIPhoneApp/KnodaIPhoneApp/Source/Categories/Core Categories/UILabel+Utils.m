//
//  UILabel+Utils.m
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 8/13/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "UILabel+Utils.h"

@implementation UILabel (Utils)

- (void)sizeToFitText {
    CGSize size = [self.text sizeWithFont:self.font constrainedToSize:CGSizeMake(self.frame.size.width, FLT_MAX) lineBreakMode:self.lineBreakMode];
    CGRect frame = self.frame;
    frame.size.height = size.height;
    self.frame = frame;
}

@end
