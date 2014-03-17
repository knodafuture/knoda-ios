//
//  HomeViewController.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/24/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "HomeViewController.h"
#import "NavigationViewController.h"
#import "ProfileViewController.h"
#import "AnotherUsersProfileViewController.h"
#import "AppDelegate.h"
#import "FirstStartView.h"
#import "UserManager.h"

@interface HomeViewController () <FirstStartViewDelegate>

@property (strong, nonatomic) NSArray *predictions;
@property (strong, nonatomic) FirstStartView *firstStartView;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:FirstLaunchKey] || ![UserManager sharedInstance].user) {
        [self showFirstStartOverlay];
    }
    
    self.title = @"HOME";
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];    
    [Flurry logEvent: @"Home_Screen" withParameters: nil timed: YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [Flurry endTimedEvent: @"Home_Screen" withParameters: nil];
}

- (void)showFirstStartOverlay {
    [Flurry logEvent: @"First_Screen_Overlay" timed: YES];
    
    self.firstStartView = [[FirstStartView alloc] initWithDelegate:self];
    [[[[UIApplication sharedApplication] delegate] window] addSubview:self.firstStartView];
}

- (void)firstStartViewDidClose:(FirstStartView *)firstStartView {
    [Flurry endTimedEvent: @"First_Screen_Overlay" withParameters: nil];
    
    [self.firstStartView removeFromSuperview];
    self.firstStartView = nil;
    self.view.userInteractionEnabled = YES;
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:FirstLaunchKey];
    
    //Check badges
    //[BadgesWebRequest checkNewBadges];
}

- (AppDelegate *)appDelegate {
    return [[UIApplication sharedApplication] delegate];
}
@end
