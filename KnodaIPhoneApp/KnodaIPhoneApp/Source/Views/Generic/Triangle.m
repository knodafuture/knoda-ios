//
//  Triangle.m
//  KnodaIPhoneApp
//
//  Created by nick on 10/18/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "Triangle.h"

@interface Triangle ()
@property (assign, nonatomic) BOOL up;
@end

@implementation Triangle

- (id)initForUp:(BOOL)up {
    self = [super initWithFrame:CGRectMake(0, 0, 24, 6)];
    self.up = up;
    
    // Build a triangular path

    
    return self;
}

- (void)awakeFromNib {
    
    UIBezierPath *path = [UIBezierPath new];

    if (self.frame.origin.y > 20) {
        [path moveToPoint:(CGPoint){0, 0}];
        [path addLineToPoint:(CGPoint){12, 6}];
        [path addLineToPoint:(CGPoint){24, 0}];
        [path addLineToPoint:(CGPoint){0, 0}];
    } else {
        [path moveToPoint:(CGPoint){0, 6}];
        [path addLineToPoint:(CGPoint){12, 0}];
        [path addLineToPoint:(CGPoint){24, 6}];
        [path addLineToPoint:(CGPoint){0, 6}];
    }
    
    // Create a CAShapeLayer with this triangular path
    // Same size as the original imageView
    CAShapeLayer *mask = [CAShapeLayer new];
    mask.frame = self.bounds;
    mask.path = path.CGPath;
    
    // Mask the imageView's layer with this shape
    self.layer.mask = mask;
}

- (void)none {
    // Build a triangular path
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path,NULL,0.0,0.0);
    CGPathAddLineToPoint(path, NULL, 12, 6);
    CGPathAddLineToPoint(path, NULL, 24, 0);
    CGPathAddLineToPoint(path, NULL, 0, 0);
    
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setPath:path];
    [shapeLayer setFillColor:[[UIColor redColor] CGColor]];
    [shapeLayer setStrokeColor:[[UIColor blackColor] CGColor]];
    [shapeLayer setBounds:self.bounds];
    [shapeLayer setAnchorPoint:CGPointMake(0.0f, 0.0f)];
    [shapeLayer setPosition:CGPointMake(0.0f, 0.0f)];
    [self.layer addSublayer:shapeLayer];
    
    CGPathRelease(path);
}

@end
