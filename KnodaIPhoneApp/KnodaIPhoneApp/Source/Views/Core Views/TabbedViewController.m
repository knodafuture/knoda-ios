//
//  TabbedViewController.m
//  KnodaIPhoneApp
//
//  Created by nick on 6/22/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "TabbedViewController.h"

@interface TabbedViewController () <UIScrollViewDelegate>
@property (strong, nonatomic) UIView *buttonsContainer;
@property (assign, nonatomic) BOOL isSetup;

@end

@implementation TabbedViewController

- (id)init {
    self = [super initWithNibName:@"TabbedViewController" bundle:[NSBundle mainBundle]];
    self.viewControllers = @[];
    self.buttons = @[];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
    label.textAlignment = NSTextAlignmentLeft;
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
    
    self.activePage = index;
    NSString *event = [NSString stringWithFormat:@"%@", next.text];
    [Flurry logEvent:event];
    
}

- (void)labelTapped:(UIGestureRecognizer *)sender {

    NSInteger index = [self.buttons indexOfObject:sender.view];
    UIViewController *vc = [self.viewControllers objectAtIndex:index];
    [self.scrollView setContentOffset:CGPointMake(vc.view.frame.origin.x, 0) animated:YES];
    [self selectIndex:index];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.isSetup)
        return;
    
    self.isSetup = YES;
    
    for (int i =0; i < self.viewControllers.count; i++) {
        UIViewController *vc = [self.viewControllers objectAtIndex:i];
        
        
        CGRect frame = vc.view.frame;
        frame.origin.y = 0;
        frame.size.height = self.scrollView.frame.size.height;
        [self.scrollView addSubview:vc.view];
        frame.origin.x = self.scrollView.frame.size.width * i;
        vc.view.frame = frame;
        
        [self addChildViewController:vc];
    }
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * self.viewControllers.count, self.scrollView.frame.size.height);
    
    
    if (self.buttons.count == 0)
        return;
    
    CGFloat totalTextWidth;
    
    for (UILabel *button in self.buttons) {
        [button sizeToFit];
        totalTextWidth = totalTextWidth + button.frame.size.width;
    }
    
    CGFloat width = self.view.frame.size.width - 40.0;
    CGFloat diff = width - totalTextWidth;
    diff = diff / 3;
    
    CGRect frame = self.headerView.frame;
    
    frame.size.width = width;
    frame.origin.x = (self.headerView.frame.size.width / 2.0) - (frame.size.width / 2.0);
    
    self.buttonsContainer = [[UIView alloc] initWithFrame:frame];
    
    CGFloat currentOffset = 0;
    
    for (int i = 0; i < self.buttons.count; i++) {
        UILabel *button = self.buttons[i];
        
        frame = button.frame;
        frame.size.width = frame.size.width + diff;
        frame.origin.x = currentOffset;
        frame.size.height = self.headerView.frame.size.height;
        currentOffset = currentOffset + frame.size.width;
        
        [self.buttonsContainer addSubview:button];
        button.frame = frame;
    }
    [self.buttons[0] setAlpha:1.0];
    
    [self.headerView addSubview:self.buttonsContainer];
}

@end
