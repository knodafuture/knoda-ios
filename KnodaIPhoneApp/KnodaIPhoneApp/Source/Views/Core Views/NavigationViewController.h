//
//  NavigationViewController.h
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/24/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//
typedef NS_ENUM(NSInteger, MenuItem) {
    MenuHome,
    MenuAlerts,
    MenuGroups,
    MenuHistory,
    MenuBadges,
    MenuProfile,
    MenuItemsCount
};

@interface NavigationViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>


- (id)initWithFirstMenuItem:(MenuItem)menuItem;
- (void)toggleNavigationPanel;
- (void)openMenuItem:(MenuItem)menuItem;

- (void)hackAnimationFinished;
@end
