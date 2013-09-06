//
//  NavigationViewController.h
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/24/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "BaseRequestingViewController.h"

typedef enum {
    MenuHome = 0,
    MenuHistory,
    MenuAlerts,
    MenuBadges,
    MenuProfile,
    MenuItemsCount
} MenuItem;

@interface NavigationViewController : BaseRequestingViewController <UITableViewDataSource>

@property (nonatomic, weak) UINavigationController *detailsController;

@property (nonatomic, assign, readonly) BOOL masterShown;

- (void) toggleNavigationPanel;

- (void)openMenuItem:(MenuItem)menuItem;

@end
