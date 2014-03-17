//
//  SideNavBarButtonItem.m
//  KnodaIPhoneApp
//
//  Created by nick on 12/13/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "SideNavBarButtonItem.h"
#import "SideNavButton.h"

@interface SideNavBarButtonItem ()
@property (strong, nonatomic) SideNavButton *sideNavButton;
@property (strong, nonatomic) UIImage *image;
@end

@implementation SideNavBarButtonItem

- (id)initWithTarget:(id)target action:(SEL)action {
    SideNavButton *button = [SideNavButton sideNavButton];
    self = [super initWithCustomView:button];
    
    self.sideNavButton = button ;
    
    self.image = [UIImage imageNamed:@"NavIcon"];
    
    [self.sideNavButton.button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [self.sideNavButton.button setImage:self.image forState:UIControlStateHighlighted];
    [self.sideNavButton.button setImage:self.image forState:UIControlStateNormal];
    [self.sideNavButton.button setImageEdgeInsets:UIEdgeInsetsMake(0, -self.image.size.width/2.0 - 3.0, 0, + self.image.size.width/2.0 + 3.0)];

    self.sideNavButton.imageView.hidden = YES;
    self.sideNavButton.label.hidden = YES;
    
    return self;
}

- (void)setAlertsCount:(NSInteger)alertsCount {
    
    if (!alertsCount) {
        self.sideNavButton.imageView.hidden = YES;
        self.sideNavButton.label.hidden = YES;
        return;
    }
    
    self.sideNavButton.label.text = [NSString stringWithFormat:@"%ld", (long)alertsCount];
    
    CGSize textSize = [self.sideNavButton.label sizeThatFits:CGSizeMake(self.sideNavButton.frame.size.width, self.sideNavButton.label.frame.size.height)];
    
    [self.sideNavButton.imageView setImage:[[UIImage imageNamed:@"NotificationBubbleBg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 7, 0, 7)]];
    
    CGRect frame = self.sideNavButton.imageView.frame;
    
    frame.size.width = textSize.width + 4.0;
    
    
    if (frame.size.width < 16.0)
        frame.size.width = 16.0;
    
    frame.origin.x = self.image.size.width;
    frame.origin.y = self.sideNavButton.frame.size.height / 2.0 - frame.size.height / 2.0 - 1.0;
    
    self.sideNavButton.imageView.frame = frame;
    
    frame = self.sideNavButton.label.frame;
    
    frame.size.width = textSize.width;
    frame.origin.x = self.sideNavButton.imageView.frame.origin.x + (self.sideNavButton.imageView.frame.size.width / 2.0) - (frame.size.width / 2.0) + .5;
    frame.origin.y = self.sideNavButton.imageView.frame.origin.y;
    self.sideNavButton.label.frame = frame;
    
    self.sideNavButton.imageView.hidden = NO;
    self.sideNavButton.label.hidden = NO;
    
}

@end
