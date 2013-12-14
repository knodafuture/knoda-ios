//
//  SideNavButton.h
//  KnodaIPhoneApp
//
//  Created by nick on 12/13/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SideNavButton : UIView

@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *label;

+ (SideNavButton *)sideNavButton;

@end
