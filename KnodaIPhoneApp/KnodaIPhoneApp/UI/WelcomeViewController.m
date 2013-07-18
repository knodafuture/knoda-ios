//
//  ViewController.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/8/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "WelcomeViewController.h"

@interface WelcomeViewController ()

@property (nonatomic, strong) IBOutlet UILabel* promotionLabel;
@property (nonatomic, strong) IBOutlet UIScrollView* pagingScroll;
@property (nonatomic, strong) IBOutlet UIView* contentView;

@end

@implementation WelcomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.promotionLabel.font = [UIFont fontWithName: @"Krona One" size: 13];
    self.pagingScroll.contentSize = self.contentView.frame.size;
}

- (void) viewDidUnload
{
    self.promotionLabel = nil;
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
