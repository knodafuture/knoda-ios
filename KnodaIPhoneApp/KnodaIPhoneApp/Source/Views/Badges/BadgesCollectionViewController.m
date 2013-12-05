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
#import "LoadingView.h"
#import "WebApi.h"

@interface BadgesCollectionViewController ()

@property (strong, nonatomic) IBOutlet UIView *noContentView;
@property (strong, nonatomic) NSArray *badges;

@end

@implementation BadgesCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(self.navigationController.viewControllers.count > 1) { //if it's not from menu - change the navigation items
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 33)];
        [btn setImage:[UIImage imageNamed:@"backArrow.png"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *barBtn = [[UIBarButtonItem alloc] initWithCustomView:btn];
        self.navigationItem.leftBarButtonItem  = barBtn;
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    self.title = @"BADGES";
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem sideNavBarBUttonItemwithTarget:self action:@selector(menuButtonPressed:)];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem addPredictionBarButtonItem];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"BadgesCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"BadgeCollectionViewCellIdentifier"];
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setUpUsersBadges];
    [Flurry logEvent: @"Badges_Screen" withParameters: nil timed: YES];
}

- (void) viewDidDisappear: (BOOL) animated {
    [super viewDidDisappear: animated];
    [Flurry endTimedEvent: @"Badges_Screen" withParameters: nil];
}

- (void)setUpUsersBadges {
    [[LoadingView sharedInstance] show];

    [[WebApi sharedInstance] getAllBadgesCompletion:^(NSArray *badges, NSError *error) {
        [[LoadingView sharedInstance] hide];
        if (!error) {
            self.badges = badges;
            [self.collectionView reloadData];
        }
        
        if (self.badges.count == 0)
            [self.view addSubview:self.noContentView];
        else
            [self.noContentView removeFromSuperview];
    }];
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
    if ( [self.badges count] % 2 == 0) {
       return [self.badges count] / 2;
    }
    else {
        return [self.badges count] / 2 + 1;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if ([self.badges count] - section * 2 > 1) {
        return 2;
    }
    else {
        return 1;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BadgeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BadgeCollectionViewCellIdentifier" forIndexPath:indexPath];
    
    Badge *badge = [self.badges objectAtIndex:(indexPath.section * 2 + indexPath.row)];
    
    cell.badgeImageView.image = [UIImage imageNamed:badge.name];
    
    return cell;
}


@end
