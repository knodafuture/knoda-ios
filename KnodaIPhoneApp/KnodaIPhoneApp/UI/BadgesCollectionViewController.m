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

@interface BadgesCollectionViewController ()

@property (nonatomic, strong) NSMutableArray * badgesImagesArray;
@property (weak, nonatomic) IBOutlet UIView *activityView;

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
        if (badgesWebRequest.errorCode == 0) {
            self.badgesImagesArray = badgesWebRequest.badgesImagesArray;
            [self.collectionView reloadData];
        }
        self.activityView.hidden = YES;
    }];
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

@end
