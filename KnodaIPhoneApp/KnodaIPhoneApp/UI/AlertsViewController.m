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
#import "AppDelegate.h"
#import "AllAlertsWebRequest.h"

static NSString* const kAddPredictionSegue = @"AddPredictionSegue";

@interface AlertsViewController () <AddPredictionViewControllerDelegate>

@property (nonatomic, strong) IBOutlet UIView* detailsView;
@property (nonatomic, strong) IBOutlet UIImageView* segmentedControlImage;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (nonatomic, strong) AppDelegate * appDelegate;
@property (nonatomic, weak) UIViewController *detailsViewController;
@property (weak, nonatomic) IBOutlet UIView *noContentView;

@end


@implementation AlertsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.frame = CGRectMake(0, 0, self.view.frame.size.width, self.navigationController.navigationBar.frame.size.height);
    self.loadingView.hidden = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    self.loadingView.hidden = NO;
    AllAlertsWebRequest* request = [[AllAlertsWebRequest alloc] init];
    __weak AlertsViewController *weakSelf = self;
    
    [request executeWithCompletionBlock: ^
     {
         if (request.errorCode == 0)
         {
             AlertsViewController *strongSelf = weakSelf;
             if(strongSelf) {
                 self.loadingView.hidden = YES;
                 request.predictions.count > 0 ? [strongSelf performSegueWithIdentifier: @"AllAlertsSegue" sender: strongSelf] : [strongSelf setUpNoContentViewHidden:NO];
             }
         }
     }];

}

- (void) setUpNoContentViewHidden: (BOOL) hidden {
    if (self.noContentView.hidden == hidden) {
        return;
    }
    self.noContentView.hidden = hidden;
    if (hidden) {
        [self.noContentView removeFromSuperview];
    }
    else {
        [self.view addSubview:self.noContentView];
    }
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
    if (self.childViewControllers.count > 0) {
        [(UIViewController<RefreshableViewController>*)[self.childViewControllers objectAtIndex: 0] refresh];
    }
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

- (AppDelegate*) appDelegate
{
    return [UIApplication sharedApplication].delegate;
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
