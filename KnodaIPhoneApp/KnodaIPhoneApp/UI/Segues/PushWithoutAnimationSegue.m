//
//  PushWithoutAnimationSegue.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/26/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "PushWithoutAnimationSegue.h"

@implementation PushWithoutAnimationSegue

- (void) perform
{
    [((UIViewController*)self.sourceViewController).navigationController pushViewController: self.destinationViewController animated: NO];
}

@end
