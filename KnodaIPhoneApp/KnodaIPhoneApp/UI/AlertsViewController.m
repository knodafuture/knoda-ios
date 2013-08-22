//
//  AlertsViewController.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/25/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "AlertsViewController.h"
#import "NavigationViewController.h"
#import "NavigationSegue.h"
#import "AddPredictionViewController.h"

static NSString* const kAddPredictionSegue = @"AddPredictionSegue";

@interface AlertsViewController () <AddPredictionViewControllerDelegate>

@property (nonatomic, strong) IBOutlet UIView* detailsView;
@property (nonatomic, strong) IBOutlet UIImageView* segmentedControlImage;

@property (nonatomic, weak) UIViewController *detailsViewController;

@end


@implementation AlertsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.frame = CGRectMake(0, 0, self.view.frame.size.width, self.navigationController.navigationBar.frame.size.height);
	
    [self performSegueWithIdentifier: @"AllAlertsSegue" sender: self];
}


- (void) prepareForSegue: (UIStoryboardSegue*) segue sender: (id) sender
{
    if([segue isKindOfClass:[NavigationSegue class]]) {
        ((NavigationSegue*)segue).detailsView = self.detailsView;
        self.detailsViewController = segue.destinationViewController;
    }
    else if ([segue.identifier isEqualToString:kAddPredictionSegue]) {
        AddPredictionViewController *vc = (AddPredictionViewController *)segue.destinationViewController;
        vc.delegate = self;
    }
}


- (IBAction) menuButtonPressed: (id) sender
{
    [((NavigationViewController*)self.navigationController.parentViewController) toggleNavigationPanel];
}


- (IBAction) lerfButtonPressed: (id) sender
{
    self.segmentedControlImage.image = [UIImage imageNamed: @"sort_left-green"];
}


- (IBAction) rightButtonPressed: (id) sender
{
    self.segmentedControlImage.image = [UIImage imageNamed: @"sort_right-green"];
}

#pragma mark - AddPredictionViewControllerDelegate

- (void) predictionWasMadeInController:(AddPredictionViewController *)vc
{
    [vc dismissViewControllerAnimated:YES completion:^{
        if([self.detailsViewController conformsToProtocol:@protocol(AddPredictionViewControllerDelegate)]) {
            [(id<AddPredictionViewControllerDelegate>)self.detailsViewController predictionWasMadeInController:nil];
        }
    }];
}

@end
