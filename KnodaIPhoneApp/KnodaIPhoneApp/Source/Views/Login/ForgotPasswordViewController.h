//
//  ForgotPasswordViewController.h
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/19/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginOverlayViewController.h"

@interface ForgotPasswordViewController : LoginOverlayViewController <UITextFieldDelegate>

-(id)initWithEmail:(NSString *)email;

@end
