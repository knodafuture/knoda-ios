//
//  SideNavBarButtonItem.h
//  KnodaIPhoneApp
//
//  Created by nick on 12/13/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SideNavButton;
@interface SideNavBarButtonItem : UIBarButtonItem

- (id)initWithTarget:(id)target action:(SEL)action;

- (void)setAlertsCount:(NSInteger)alertsCount;

@end
