//
//  BadgesCollectionViewController.m
//  KnodaIPhoneApp
//
//  Created by Vyacheslav Nechiporenko on 8/19/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "BadgesCollectionViewController.h"
#import "BadgeCollectionViewCell.h"
#import "NavigationViewController.h"
#import "BadgesWebRequest.h"
#import "AddPredictionViewController.h"
#import "UIViewController+WebRequests.h"
#import "LoadingView.h"

static NSString* const kAddPredictionSegue = @"AddPredictionSegue";

@interface BadgesCollectionViewController () <AddPredictionViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray * badgesImagesArray;
@property (weak, nonatomic) IBOutlet UIView *noContentView;

@property (nonatomic) NSMutableArray *webRequests;

@end

@implementation BadgesCollectionViewController

- (void)dealloc {
    [self cancelAllRequests];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.webRequests = [NSMutableArray array];
    
    if(self.navigationController.viewControllers.count > 1) { //if it's not from menu - change the navigation items
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 33)];
        [btn setImage:[UIImage imageNamed:@"backArrow.png"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *barBtn = [[UIBarButtonItem alloc] initWithCustomView:btn];
        self.navigationItem.leftBarButtonItem  = barBtn;
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    [[LoadingView sharedInstance] show];
    self.navigationController.navigationBar.frame = CGRectMake(0, 0, self.view.frame.size.width, self.navigationController.navigationBar.frame.size.height);
    [self.navigationController.navigationBar setTitleVerticalPositionAdjustment:5 forBarMetrics:UIBarMetricsDefault];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setUpUsersBadges];
    [Flurry logEvent: @"Badges_Screen" withParameters: nil timed: YES];
}

- (void) viewDidDisappear: (BOOL) animated
{
    [super viewDidDisappear: animated];
    [Flurry endTimedEvent: @"Badges_Screen" withParameters: nil];
}

- (NSMutableArray *)getWebRequests {
    return self.webRequests;
}

- (void) setUpUsersBadges {
    __weak BadgesCollectionViewController *weakSelf = self;
    BadgesWebRequest * badgesWebRequest = [[BadgesWebRequest alloc]init];
    [self executeRequest:badgesWebRequest withBlock:^{
        [[LoadingView sharedInstance] hide];
        
        BadgesCollectionViewController *strongSelf = weakSelf;
        if(!strongSelf) return;
        
        if (badgesWebRequest.errorCode == 0) {
            strongSelf.badgesImagesArray = badgesWebRequest.badgesImagesArray;
            [strongSelf.collectionView reloadData];
        }
        
        if ([strongSelf.badgesImagesArray count] == 0) {
            strongSelf.noContentView.hidden = NO;
            strongSelf.view = strongSelf.noContentView;
        }
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kAddPredictionSegue]) {
        AddPredictionViewController *vc =(AddPredictionViewController*)segue.destinationViewController;
        vc.delegate = self;
    }
}

#pragma mark - Outlets actions

- (IBAction)menuButtonPressed:(id)sender {
    [((NavigationViewController*)self.navigationController.parentViewController) toggleNavigationPanel];
}

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if ( [self.badgesImagesArray count] % 2 == 0) {
       return [self.badgesImagesArray count] / 2;
    }
    else {
        return [self.badgesImagesArray count] / 2 + 1;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if ([self.badgesImagesArray count] - section * 2 > 1) {
        return 2;
    }
    else {
        return 1;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BadgeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BadgeCollectionViewCellIdentifier" forIndexPath:indexPath];
    cell.badgeImageView.image = self.badgesImagesArray[(indexPath.section*2 + indexPath.row)];
    return cell;
}

#pragma mark - AddPredictionViewControllerDelegate

- (void) predictionWasMadeInController:(AddPredictionViewController *)vc
{
    [vc dismissViewControllerAnimated:YES completion:nil];
}


@end
