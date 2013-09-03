//
//  ParentViewController.m
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 02.09.13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "ParentViewController.h"
#import "NavigationSegue.h"
#import "AddPredictionViewController.h"

static NSString* const kAddPredictionSegue = @"AddPredictionSegue";

@interface ParentViewController () <AddPredictionViewControllerDelegate>

@property (nonatomic, weak) ChildViewController *childViewController;
@property (nonatomic) NSMutableDictionary *childrenCache;

@end

@implementation ParentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.childrenCache = [NSMutableDictionary dictionary];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue isKindOfClass:[NavigationSegue class]]) {
        ((NavigationSegue*)segue).detailsView = self.detailsView;
        self.childViewController = segue.destinationViewController;
        self.childViewController.childDataSource = self;
    }
    else if ([segue.identifier isEqualToString:kAddPredictionSegue]) {
        AddPredictionViewController *vc = (AddPredictionViewController *)segue.destinationViewController;
        vc.delegate = self;
    }
}

#pragma mark Actions

- (IBAction) lerfButtonPressed: (id) sender
{
    self.segmentedControlImage.image = [UIImage imageNamed: @"sort_left-green"];
}


- (IBAction) rightButtonPressed: (id) sender
{
    self.segmentedControlImage.image = [UIImage imageNamed: @"sort_right-green"];
}

#pragma mark - ChildControllerDataSource

- (NSArray *)cachedDataForController:(UIViewController *)vc {
    NSString *key = [NSString stringWithFormat:@"%@_data", NSStringFromClass([vc class])];
    return self.childrenCache[key];
}

- (void)cacheData:(NSArray *)data forController:(UIViewController *)vc {
    if(!data.count) {
        return;
    }
    NSString *key = [NSString stringWithFormat:@"%@_data", NSStringFromClass([vc class])];
    self.childrenCache[key] = data;
}

#pragma mark - AddPredictionViewControllerDelegate

- (void) predictionWasMadeInController:(AddPredictionViewController *)vc
{
    [vc dismissViewControllerAnimated:YES completion:^{
        if([self.childViewController conformsToProtocol:@protocol(AddPredictionViewControllerDelegate)]) {
            [(id<AddPredictionViewControllerDelegate>)self.childViewController predictionWasMadeInController:nil];
        }
    }];
}

@end
