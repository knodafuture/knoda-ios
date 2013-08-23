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

static NSString* const kAddPredictionSegue = @"AddPredictionSegue";

@interface BadgesCollectionViewController () <AddPredictionViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray * badgesImagesArray;
@property (weak, nonatomic) IBOutlet UIView *activityView;
@property (weak, nonatomic) IBOutlet UIView *noContentView;

@end

@implementation BadgesCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.activityView.hidden = NO;
    self.navigationController.navigationBar.frame = CGRectMake(0, 0, self.view.frame.size.width, self.navigationController.navigationBar.frame.size.height);
    [self setUpUsersBadges];
}

- (void) setUpUsersBadges {
    BadgesWebRequest * badgesWebRequest = [[BadgesWebRequest alloc]init];
    [badgesWebRequest executeWithCompletionBlock:^{
        self.activityView.hidden = YES;
        if (badgesWebRequest.errorCode == 0) {
            self.badgesImagesArray = badgesWebRequest.badgesImagesArray;
            [self.collectionView reloadData];
        }
        
        if ([self.badgesImagesArray count] == 0) {
            self.noContentView.hidden = NO;
            self.view = self.noContentView;
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
