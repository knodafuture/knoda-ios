//
//  UsernameEmailChangeViewController.h
//  KnodaIPhoneApp
//
//  Created by Vyacheslav Nechiporenko on 8/28/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM( NSUInteger, UserPropertyType ) {
    UserPropertyTypeUsername,
    UserPropertyTypeEmail
};

@interface UsernameEmailChangeViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, assign) UserPropertyType userProperyChangeType;
@property (nonatomic, strong) NSString *currentPropertyValue;

- (IBAction)backButtonPressed:(id)sender;
- (IBAction)saveButonTouched:(id)sender;

@end
