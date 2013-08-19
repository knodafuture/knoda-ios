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


@interface AlertCell ()

@property (nonatomic, strong) IBOutlet UIImageView* alertMarkImageView;
@property (nonatomic, strong) IBOutlet UILabel* alertTitle;

@end


@implementation AlertCell


- (void) update
{
    [super update];
    self.alertMarkImageView.image = [UIImage imageNamed: ((self.prediction.chellange.isOwn) ? @"exclamation" : ((self.prediction.chellange.isRight) ? @"check" : @"x_lost"))];
    self.alertTitle.text = NSLocalizedString(((self.prediction.chellange.isOwn) ? @"Your prediction expired." : ((self.prediction.chellange.isRight) ? @"You won." : @"You lost.")), @"");
}


@end
