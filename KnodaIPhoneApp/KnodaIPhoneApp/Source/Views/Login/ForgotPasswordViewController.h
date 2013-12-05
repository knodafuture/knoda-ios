//
//  ForgotPasswordViewController.h
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/19/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForgotPasswordViewController : UIViewController <UITextFieldDelegate>

-(id)initWithEmail:(NSString *)email;

@end
