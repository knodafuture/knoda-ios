//
//  NewBadgeView.h
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 23.08.13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewBadgeView : UIView

+ (void)showWithBadge:(UIImage *)badgeImage;

- (IBAction)viewBadges:(UIButton *)sender;
- (IBAction)close:(UIButton *)sender;

@end