//
//  GenericWalkthroughView.m
//  KnodaIPhoneApp
//
//  Created by nick on 10/18/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "GenericWalkthroughView.h"
#import "UIView+Utils.h"    
#import "UIImage+ImageEffects.h"
#import "Triangle.h"

static UINib *nib;

@implementation GenericWalkthroughView

+ (void)initialize {
    nib = [UINib nibWithNibName:@"GenericWalkthroughView" bundle:[NSBundle mainBundle]];
}

- (id)init {
    self = [[nib instantiateWithOwner:nil options:nil] lastObject];
    
    CGRect frame = self.bounds;
    
    frame.size.width = [UIScreen mainScreen].bounds.size.width;
    
    self.frame = frame;
    
    return self;
}


- (void)addBlur:(UIView *)backgroundView destinationRect:(CGRect)rect {
    
    UIImage *capture = [backgroundView captureView];
    CGImageRef croppedRef = CGImageCreateWithImageInRect(capture.CGImage, CGRectMake(0, rect.origin.y, self.frame.size.width, self.frame.size.height));

    UIImage *croppedImage = [UIImage imageWithCGImage:croppedRef];
    
    croppedImage = [croppedImage applyExtraLightEffect];
    
    UIImageView *background = [[UIImageView alloc] initWithImage:croppedImage];
    [self insertSubview:background atIndex:0];
    
    self.frame = rect;
}

- (void)prepareWithTitle:(NSString *)title body:(NSString *)body direction:(BOOL)up {
    self.upTriangle.hidden = !up;
    self.downTriangle.hidden = !self.upTriangle.hidden;
    self.titleLabel.text = title;
    self.bodyLabel.text = body;
    self.alpha = 0.0;
    
    
}

- (void)smallerFont {
    UIFont *font = self.bodyLabel.font;
    self.bodyLabel.font = [UIFont fontWithName:font.fontName size:font.pointSize - 2.0];
}




@end
