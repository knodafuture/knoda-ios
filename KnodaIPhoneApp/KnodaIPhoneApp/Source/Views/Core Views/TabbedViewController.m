//
//  TabbedViewController.m
//  KnodaIPhoneApp
//
//  Created by nick on 6/22/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "TabbedViewController.h"

@interface TabbedViewController () <UIScrollViewDelegate>
@end

@implementation TabbedViewController

- (id)init {
    self = [super initWithNibName:@"TabbedViewController" bundle:[NSBundle mainBundle]];
    self.viewControllers = @[];
    self.buttons = @[];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scrollView.scrollsToTop = NO;
}

- (void)addViewController:(UIViewController *)viewController title:(NSString *)title {
    
    NSMutableArray *mutableCopy = self.viewControllers.mutableCopy;
    [mutableCopy addObject:viewController];
    self.viewControllers = [NSArray arrayWithArray:mutableCopy];
    
    UILabel *header = [self headerLabel];
    header.text = title;
    
    mutableCopy = self.buttons.mutableCopy;
    [mutableCopy addObject:header];
    
    self.buttons = [NSArray arrayWithArray:mutableCopy];
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat pageWidth = scrollView.frame.size.width;
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    [self selectIndex:page];
}

- (UILabel *)headerLabel {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.headerView.frame.size.width * .25, self.headerView.frame.size.height)];
    label.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
    label.textColor = [UIColor whiteColor];
    label.userInteractionEnabled = YES;
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTapped:)];
    [label addGestureRecognizer:tap];
    label.alpha = 0.25;
    return label;
}

- (void)selectIndex:(NSInteger)index {
    if (self.activePage == index)
        return;
    
    UILabel *current = [self.buttons objectAtIndex:self.activePage];
    UILabel *next = [self.buttons objectAtIndex:index];
    
    [UIView animateWithDuration:0.5 animations:^{
        current.alpha = 0.25;
        next.alpha = 1.0;
    }];
    [self didMoveFromIndex:self.activePage toIndex:index];
    self.activePage = index;
    NSString *event = [NSString stringWithFormat:@"%@", next.text];
    [Flurry logEvent:event];
    
    
    CGRect centeredRect = CGRectMake(next.frame.origin.x + next.frame.size.width/2.0 - self.headerView.frame.size.width/2.0,
                                     0,
                                     self.headerView.frame.size.width,
                                     self.headerView.frame.size.height);
    [self.headerView scrollRectToVisible:centeredRect animated:YES];
    
    CGRect frame = self.scrollIndicator.frame;
    if ([self shouldScrollHeader])
        frame.origin.x = (self.headerView.frame.size.width / 3) * index;
    else
        frame.origin.x = (self.headerView.frame.size.width / self.buttons.count) * index;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.scrollIndicator.frame = frame;
    }];
    
}

- (void)didMoveFromIndex:(NSInteger)index toIndex:(NSInteger)newIndex {
    
}

- (void)labelTapped:(UIGestureRecognizer *)sender {

    NSInteger index = [self.buttons indexOfObject:sender.view];
    UIViewController *vc = [self.viewControllers objectAtIndex:index];
    [self.scrollView setContentOffset:CGPointMake(vc.view.frame.origin.x, 0) animated:YES];
    [self selectIndex:index];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.headerView.scrollEnabled = NO;
    if (self.isSetup)
        return;
    
    self.isSetup = YES;
    
    for (int i =0; i < self.viewControllers.count; i++) {
        UIViewController *vc = [self.viewControllers objectAtIndex:i];
        
        
        CGRect frame = vc.view.frame;
        frame.origin.y = 0;
        frame.size = self.scrollView.frame.size;
        [self.scrollView addSubview:vc.view];
        frame.origin.x = self.scrollView.frame.size.width * i;
        vc.view.frame = frame;
        
        [self addChildViewController:vc];
    }
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * self.viewControllers.count, self.scrollView.frame.size.height);
    
    if ([self shouldScrollHeader]) {
        for (int i = 0; i < self.buttons.count; i++) {
            UILabel *label = self.buttons[i];
            CGRect frame = label.frame;
            frame.size.width = self.headerView.frame.size.width / 3.0;
            frame.origin.x = i * frame.size.width;
            label.frame = frame;
            label.textAlignment = NSTextAlignmentCenter;
            [self.headerView addSubview:label];
        }
        self.headerView.contentSize = CGSizeMake((self.headerView.frame.size.width / 3.0) * self.buttons.count, self.headerView.frame.size.height);
        
    } else {
        for (int i = 0; i < self.buttons.count; i++) {
            UILabel *button = self.buttons[i];
            CGRect frame;
            frame = button.frame;
            frame.size.width = self.headerView.frame.size.width / self.buttons.count;
            frame.origin.x = frame.size.width * i;
            frame.size.height = self.headerView.frame.size.height;
            
            [self.headerView addSubview:button];
            button.frame = frame;
        }
    }
    [self.buttons[0] setAlpha:1.0];
    
    self.scrollIndicator = [[UIView alloc] initWithFrame:CGRectMake(0, self.headerView.frame.size.height - 2.0, self.headerView.frame.size.width / self.buttons.count, 2)];
    self.scrollIndicator.backgroundColor = [UIColor colorFromHex:@"235c37"];
    
    
    if (self.buttons.count < 3)
        self.scrollIndicator.hidden = YES;
    else if ([self shouldScrollHeader]){
        CGRect frame = self.scrollIndicator.frame;
        frame.size.width = self.headerView.frame.size.width / 3.0;
        self.scrollIndicator.frame = frame;
    }
    [self.headerView addSubview:self.scrollIndicator];

}

- (BOOL)shouldScrollHeader {
    return NO;
}

@end
