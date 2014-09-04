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


UIKIT_EXTERN NSString *UserLoggedInNotificationName;
UIKIT_EXTERN NSString *UserLoggedOutNotificationName;
UIKIT_EXTERN NSString *GetStartedNotificationName;

@class NavigationViewController;

@protocol NavigationViewControllerDelegate <NSObject>

- (void)viewDidAppearInNavigationViewController:(NavigationViewController *)viewController;
- (void)viewDidDisappearInNavigationViewController:(NavigationViewController *)viewController;
@end

@interface NavigationViewController : UIViewController

@property (strong, nonatomic) NSURL *launchUrl;
@property (assign, nonatomic) BOOL tabBarEnabled;
@property (assign, nonatomic) NSInteger unseenAlertsCount;

- (id)initWithPushInfo:(NSDictionary *)pushInfo;
- (void)openMenuItem:(MenuItem)menuItem;
- (void)handleOpenUrl:(NSURL *)url;
- (void)handlePushInfo:(NSDictionary *)pushInfo;

@end
