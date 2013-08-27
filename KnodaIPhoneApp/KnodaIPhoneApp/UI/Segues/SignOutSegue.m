//
//  SignOutSegue.m
//  KnodaIPhoneApp
//
//  Created by Vyacheslav Nechiporenko on 8/20/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "SignOutSegue.h"
#import <QuartzCore/QuartzCore.h>

@implementation SignOutSegue

- (void) perform {
    UIViewController *sourceController = (UIViewController *)self.sourceViewController;
    sourceController.parentViewController.navigationController.viewControllers =  @[self.destinationViewController];
}

@end
