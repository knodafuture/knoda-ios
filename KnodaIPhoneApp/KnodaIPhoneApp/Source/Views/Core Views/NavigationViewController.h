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
    MenuProfile,
    MenuItemsCount
};

@class NavigationViewController;

@protocol NavigationViewControllerDelegate <NSObject>

- (void)viewDidAppearInNavigationViewController:(NavigationViewController *)viewController;
- (void)viewDidDisappearInNavigationViewController:(NavigationViewController *)viewController;
@end

@interface NavigationViewController : UIViewController

@property (strong, nonatomic) NSURL *launchUrl;

- (id)initWithPushInfo:(NSDictionary *)pushInfo;
- (void)openMenuItem:(MenuItem)menuItem;
- (void)handleOpenUrl:(NSURL *)url;
- (void)handlePushInfo:(NSDictionary *)pushInfo;
- (void)hackAnimationFinished;
@end
