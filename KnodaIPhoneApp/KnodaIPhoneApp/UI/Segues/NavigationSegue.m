//
//  NavegationSegue.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/24/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "NavigationSegue.h"

@implementation NavigationSegue

- (void) perform
{
    for (UIViewController* childController in ((UIViewController*)self.sourceViewController).childViewControllers)
    {
        [childController removeFromParentViewController];
    }
    
    for (UIView* subview in self.detailsView.subviews)
    {
        [subview removeFromSuperview];
    }
    
    [self.detailsView addSubview: ((UIViewController*)self.destinationViewController).view];
    [((UIViewController*)self.sourceViewController) addChildViewController: ((UIViewController*)self.destinationViewController)];
    
    if (self.completion != nil)
    {
        self.completion();
    }
}

@end
