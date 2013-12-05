//
//  FirstStartView.m
//  KnodaIPhoneApp
//
//  Created by nick on 12/10/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "FirstStartView.h"

@interface FirstStartView ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation FirstStartView

- (id)initWithDelegate:(id<FirstStartViewDelegate>)delegate {
    self = [[[UINib nibWithNibName:@"FirstStartView" bundle:[NSBundle mainBundle]] instantiateWithOwner:nil options:nil] lastObject];
    self.delegate = delegate;
    self.backgroundColor = [UIColor clearColor];
    
    if ([UIScreen mainScreen].bounds.size.height > 480)
        self.imageView.image = [UIImage imageNamed:@"IntroOverlay@2x-568h.png"];
    else
        self.imageView.image = [UIImage imageNamed:@"IntroOverlay"];
    
    return self;
}

- (IBAction)close:(id)sender {
    [self.delegate firstStartViewDidClose:self];
}

@end
