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
    [[(UIViewController *)self.sourceViewController childViewControllers] makeObjectsPerformSelector:@selector(willMoveToParentViewController:) withObject:nil];
    
    [self.detailsView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [[(UIViewController *)self.sourceViewController childViewControllers] makeObjectsPerformSelector:@selector(removeFromParentViewController)];
    
    
    [((UIViewController*)self.sourceViewController) addChildViewController: self.destinationViewController];
    
    ((UIViewController*)self.destinationViewController).view.frame = self.detailsView.bounds;
    [self.detailsView addSubview: ((UIViewController*)self.destinationViewController).view];
    
    [((UIViewController*)self.destinationViewController) didMoveToParentViewController: self.sourceViewController];
    

    if (self.completion != nil)
    {
        self.completion();
    }
}

@end
