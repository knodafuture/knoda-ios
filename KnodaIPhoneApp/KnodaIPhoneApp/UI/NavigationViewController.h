//
//  NavigationViewController.h
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/24/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NavigationViewController : UIViewController <UITableViewDataSource>

@property (nonatomic, weak) UINavigationController *detailsController;

- (void) toggleNavigationPanel;

@end
