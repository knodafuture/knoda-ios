//
//  GenericWalkthroughView.h
//  KnodaIPhoneApp
//
//  Created by nick on 10/18/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Triangle;
@interface GenericWalkthroughView : UIView

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *bodyLabel;
@property (weak, nonatomic) IBOutlet Triangle *upTriangle;
@property (weak, nonatomic) IBOutlet Triangle *downTriangle;
@property (weak, nonatomic) IBOutlet UIView *curtain;

- (void)addBlur:(UIView *)backgroundView destinationRect:(CGRect)rect;

- (void)prepareWithTitle:(NSString *)title body:(NSString *)body direction:(BOOL)up;

- (void)smallerFont;
@end
