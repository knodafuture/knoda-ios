//
//  AlertNavigationCell.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 8/29/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "AlertNavigationCell.h"


@interface AlertNavigationCell ()

@property (nonatomic, strong) IBOutlet UIImageView* badgeImage;
@property (nonatomic, strong) IBOutlet UILabel* badgeLabel;

@end


@implementation AlertNavigationCell


- (void) updateBadge: (NSInteger) badgeValue
{
    self.badgeLabel.text = [NSString stringWithFormat: @"%d", badgeValue];
    
    if (badgeValue == 0)
    {
        self.badgeImage.hidden = YES;
        self.badgeLabel.hidden = YES;
    }
    else
    {
        self.badgeImage.hidden = NO;
        self.badgeLabel.hidden = NO;
    }
}


@end
