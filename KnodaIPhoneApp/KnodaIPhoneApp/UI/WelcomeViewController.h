//
//  ViewController.h
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/8/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WelcomeViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *screen1;
@property (weak, nonatomic) IBOutlet UIImageView *screen2;
@property (weak, nonatomic) IBOutlet UIImageView *screen3;
@property (weak, nonatomic) IBOutlet UIImageView *screen4;
@property (weak, nonatomic) IBOutlet UIImageView *screen5;

@property (weak, nonatomic) IBOutlet UILabel *swipeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *swipeArrow;
@end
