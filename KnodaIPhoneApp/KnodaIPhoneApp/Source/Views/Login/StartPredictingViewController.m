//
//  StartPredictionViewController.m
//  KnodaIPhoneApp
//
//  Created by nick on 8/14/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "StartPredictingViewController.h"
#import "UserManager.h"
#import "NavigationViewController.h"
#import "WebApi.h"
#import "AppDelegate.h"
#import "WalkthroughController.h"
#import "ContestWalkthroughController.h"

@interface StartPredictingViewController ()
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) UIImage *image;
@end

@implementation StartPredictingViewController

- (id)initWithImage:(UIImage *)image {
    self = [super initWithNibName:@"StartPredictingViewController" bundle:[NSBundle mainBundle]];
    self.image = image;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.translucent = NO;

    self.imageView.layer.cornerRadius = self.imageView.frame.size.height / 2.0;
    self.imageView.clipsToBounds = YES;
    
    
    self.imageView.layer.borderColor = [UIColor colorFromHex:@"efefef"].CGColor;
    self.imageView.layer.borderWidth = 1.0;
    if (self.image)
        self.imageView.image = self.image;
    
    else
        [[WebApi sharedInstance] getImage:[UserManager sharedInstance].user.avatar.big completion:^(UIImage *image, NSError *error) {
            self.imageView.image = image;
        }];
    self.label.text = [NSString stringWithFormat:@"%@,", [UserManager sharedInstance].user.name];
    self.title = [UserManager sharedInstance].user.name;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.hidesBackButton = YES;
}

- (IBAction)startPredicting:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:FirstLaunchKey];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:PredictWalkthroughCompleteKey];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:VotingWalkthroughCompleteKey];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:ContestSuccessWalkthroughNotificationKey];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:ContestVoteWalkthroughNotificationKey];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:VotingDateWalkthroughCompleteKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:UserLoggedInNotificationName object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:GetStartedNotificationName object:nil];
}

@end
