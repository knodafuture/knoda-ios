//
//  LoginOverlayViewController.m
//  KnodaIPhoneApp
//
//  Created by nick on 8/14/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "LoginOverlayViewController.h"
#import "HomeViewController.h"
#import "UIImage+ImageEffects.h"

#define TRANSITION_DURATION 0.5

static UIImage *backgroundImage;

@interface LoginOverlayViewController () <UIViewControllerAnimatedTransitioning>
@property (strong, nonatomic) UIView *overlay;
@property (assign, nonatomic) UINavigationControllerOperation operation;
@end

@implementation LoginOverlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processImage:) name:HomeViewLoadedNotificationName object:nil];
    UIView *overlay = [[UIView alloc] initWithFrame:self.view.bounds];
    overlay.backgroundColor = [UIColor colorFromHex:@"77bc1f"];
    overlay.alpha = 0.75;
    self.overlay = overlay;
    [self.view insertSubview:overlay atIndex:0];
    
    self.navigationController.navigationBar.translucent = YES;
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)setupBackground {
    
    self.navigationController.view.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    
    self.overlay.frame = self.view.bounds;
    
    self.navigationController.delegate = self;

    
}

- (void)processImage:(NSNotification *)notification {
    if (backgroundImage)
        return;
    
    UIImage *capture = notification.userInfo[HomeViewCaptureKey];
    
    CGImageRef croppedRef = CGImageCreateWithImageInRect(capture.CGImage, CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height));
    
    UIImage *croppedImage = [UIImage imageWithCGImage:croppedRef];
    CGImageRelease(croppedRef);
    
    UIImage *navBackground = [croppedImage applyExtraLightEffectWithTintColor:[UIColor colorFromHex:@"77bc1f"]];
    
    //[self.navigationController.navigationBar setBackgroundImage:cropped forBarMetrics:UIBarMetricsDefault];
    
    //[self setupBackground];
}

- (void)dealloc {
    [self removeAllObservations];
}
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController     *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC {
    self.operation = operation;
    
    return self;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    // the containerView is the superview during the animation process.
    UIView *container = transitionContext.containerView;
    
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *fromView = fromVC.view;
    UIView *toView = toVC.view;
    CGFloat containerWidth = container.frame.size.width;
    
    // Set the needed frames to animate.
    
    CGRect toInitialFrame = [container frame];
    toInitialFrame.origin.y = toView.frame.origin.y;
    toInitialFrame.size.height = toView.frame.size.height;
    CGRect fromDestinationFrame = fromView.frame;
    
    if (self.operation == UINavigationControllerOperationPush)
    {
        toInitialFrame.origin.x = containerWidth;
        toView.frame = toInitialFrame;
        fromDestinationFrame.origin.x = -containerWidth;
    }
    else if (self.operation == UINavigationControllerOperationPop)
    {
        toInitialFrame.origin.x = -containerWidth;
        toView.frame = toInitialFrame;
        fromDestinationFrame.origin.x = containerWidth;
    }
    
    // Create a screenshot of the toView.
    UIView *move = [toView snapshotViewAfterScreenUpdates:YES];
    CGRect moveFrame = toInitialFrame;
    move.frame = moveFrame;
    [container addSubview:move];
    
    [UIView animateWithDuration:TRANSITION_DURATION delay:0
         usingSpringWithDamping:1000 initialSpringVelocity:1
                        options:0 animations:^{
                            CGRect frame = move.frame;
                            frame.origin.x = container.frame.origin.x;
                            move.frame = frame;
                            fromView.frame = fromDestinationFrame;
                        }
                     completion:^(BOOL finished) {
                         if (![[container subviews] containsObject:toView])
                         {
                             [container addSubview:toView];
                         }
                         CGRect frame = toInitialFrame;
                         frame.origin.x = 0;
                         toView.frame = frame;
                         [fromView removeFromSuperview];
                         [move removeFromSuperview];
                         [transitionContext completeTransition: YES];
                     }];
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return TRANSITION_DURATION;
}

@end
