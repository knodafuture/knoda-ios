//
//  NavigationViewController.h
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/24/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    MenuHome = 0,
    MenuHistory,
    MenuAlerts,
    MenuBadges,
    MenuProfile,
    MenuItemsSize
} MenuItem;

@interface NavigationViewController : UIViewController <UITableViewDataSource>

@property (nonatomic, weak) UINavigationController *detailsController;

@property (nonatomic, assign, readonly) BOOL masterShown;

- (void) toggleNavigationPanel;

- (void)openMenuItem:(MenuItem)menuItem;

@end
