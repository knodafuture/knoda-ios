//
//  TabbedViewController.h
//  KnodaIPhoneApp
//
//  Created by nick on 6/22/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TabbedViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *headerView;
@property (assign, nonatomic) NSInteger activePage;
@property (strong, nonatomic) NSArray *viewControllers;
@property (strong, nonatomic) NSArray *buttons;
@property (assign, nonatomic) BOOL isSetup;


- (void)addViewController:(UIViewController *)viewController title:(NSString *)title;
- (void)selectIndex:(NSInteger)index;
- (void)didMoveFromIndex:(NSInteger)index toIndex:(NSInteger)newIndex;

- (BOOL)shouldScrollHeader;
@end
