//
//  SideNavButton.m
//  KnodaIPhoneApp
//
//  Created by nick on 12/13/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "SideNavButton.h"

static UINib *nib;

@implementation SideNavButton

+ (void)initialize {
    nib = [UINib nibWithNibName:@"SideNavButton" bundle:[NSBundle mainBundle]];
}

+ (SideNavButton *)sideNavButton {
    return [[nib instantiateWithOwner:nil options:nil] lastObject];
}

@end
