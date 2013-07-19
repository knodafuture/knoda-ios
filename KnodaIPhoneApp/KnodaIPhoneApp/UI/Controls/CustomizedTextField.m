//
//  CustomizedTextField.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/17/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "CustomizedTextField.h"

@implementation CustomizedTextField

- (void) drawPlaceholderInRect: (CGRect) rect
{
    [[UIColor lightGrayColor] setFill];
    [[self placeholder] drawInRect: rect withFont: [UIFont fontWithName: @"HelveticaNeue-Italic" size: 14]];
}

@end
