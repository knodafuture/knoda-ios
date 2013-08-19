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

@interface BadgesCollectionViewController ()

@property (nonatomic, strong) NSArray * badgesImagesArray;

@end

@implementation BadgesCollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.frame = CGRectMake(0, 0, self.view.frame.size.width, self.navigationController.navigationBar.frame.size.height);
    self.badgesImagesArray = [NSArray arrayWithObjects:
                              [UIImage imageNamed:@"gold_founding"],
                              [UIImage imageNamed:@"silver_founding"],
                              [UIImage imageNamed:@"1_prediction"],
                              [UIImage imageNamed:@"10_predictions"],
                              [UIImage imageNamed:@"1_challenge"],
                              [UIImage imageNamed:@"10_correct_predictions"],
                              [UIImage imageNamed:@"10_incorrect_predictions"],nil];
	// Do any additional setup after loading the view.
}

- (IBAction)menuButtonPressed:(id)sender {
        [((NavigationViewController*)self.navigationController.parentViewController) toggleNavigationPanel];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 4;
//    return [self.badgesImagesArray count] / 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == 3) {
        return 1;
    }
    else {
        return 2;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BadgeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BadgeCollectionViewCellIdentifier" forIndexPath:indexPath];
    cell.badgeImageView.image = self.badgesImagesArray[(indexPath.section*2 + indexPath.row)];
    return cell;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
