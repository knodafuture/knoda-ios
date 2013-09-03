//
//  BaseRequestingViewController.m
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 03.09.13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "BaseRequestingViewController.h"

@interface BaseRequestingViewController ()

@property (nonatomic) NSMutableArray *webRequests;

@end

@implementation BaseRequestingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webRequests = [NSMutableArray array];
}

- (NSMutableArray *)getWebRequests {
    return self.webRequests;
}

@end
