//
//  ChildViewController.m
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 02.09.13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "ChildViewController.h"
#import "ChildControllerDataSource.h"

@interface ChildViewController ()

@end

@implementation ChildViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSArray *cachedData = [self.childDataSource cachedDataForController:self];
    self.predictions = cachedData.count ? [NSMutableArray arrayWithArray:cachedData] : [NSMutableArray array];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if(self.predictions.count > [self limitByPage] && [self limitByPage] > 0) {
        [self.childDataSource cacheData:[self.predictions subarrayWithRange:NSMakeRange(0, [self limitByPage])] forController:self];
    }
    else {
        [self.childDataSource cacheData:self.predictions forController:self];
    }
}

- (NSInteger)limitByPage {
    return 0;
}

@end
