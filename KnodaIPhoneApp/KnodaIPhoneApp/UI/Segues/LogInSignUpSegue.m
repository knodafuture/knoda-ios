//
//  LogInSignUpSegue.m
//  KnodaIPhoneApp
//
//  Created by Vyacheslav Nechiporenko on 8/27/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "LogInSignUpSegue.h"

@implementation LogInSignUpSegue

- (void) perform {
    
    NSArray *sourceControllers = ((UIViewController *)self.sourceViewController).navigationController.viewControllers;
    sourceControllers = [NSArray arrayWithObjects:sourceControllers[0],self.destinationViewController, nil];
    
    [((UIViewController *)self.destinationViewController).view setAlpha:0];
    
    [UIView animateWithDuration:.33 animations:^{
        
        [[((UIViewController *)self.sourceViewController).navigationController.viewControllers[1] view] setAlpha:0];
        
    } completion:^(BOOL finished) {
        
        ((UIViewController *)self.sourceViewController).navigationController.viewControllers = sourceControllers;
        
        [UIView animateWithDuration:.33 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            
            [((UIViewController *)self.destinationViewController).view setAlpha:1];

        } completion:nil];
    }];
}

@end
