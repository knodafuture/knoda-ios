//
//  AlertCell.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 8/19/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "AlertCell.h"
#import "Prediction.h"
#import "Chellange.h"
#import "BindableView.h"

@interface AlertCell ()

@property (nonatomic, weak) IBOutlet UIImageView* alertMarkImageView;
@property (nonatomic, weak) IBOutlet UILabel* alertTitle;
@property (nonatomic, weak) IBOutlet BindableView *avatarView;

@end


@implementation AlertCell


- (void) update
{
    [super update];
    self.alertMarkImageView.image = [UIImage imageNamed: ((self.prediction.chellange.isOwn && !self.prediction.settled) ? @"exclamation" : ((self.prediction.chellange.isRight) ? @"check" : @"x_lost"))];
    self.alertTitle.text = NSLocalizedString(((self.prediction.chellange.isOwn && !self.prediction.settled) ? @"Your prediction expired." : ((self.prediction.chellange.isRight) ? @"You won." : @"You lost.")), @"");
    [self.avatarView bindToURL:self.prediction.smallAvatar];
}


@end
