//
//  PredictionsViewController.m
//  KnodaIPhoneApp
//
//  Created by nick on 12/6/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "PredictionsViewController.h"
#import "WebApi.h"
#import "PredictionCell.h"
#import "AppDelegate.h"
#import "ProfileViewController.h"
#import "AnotherUsersProfileViewController.h"
#import "PredictionDetailsViewController.h"

@interface PredictionsViewController ()
@property (strong, nonatomic) NSTimer *refreshTimer;
@property (readonly, nonatomic) AppDelegate *appDelegate;
@end

@implementation PredictionsViewController

- (AppDelegate *)appDelegate {
    return [[UIApplication sharedApplication] delegate];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(refreshVisibleCells) userInfo:nil repeats:YES];
    [self observeProperty:@keypath(self.appDelegate.currentUser) withBlock:^(__weak PredictionsViewController *self, id old, id new) {
        [self.tableView reloadData];
    }];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.refreshTimer invalidate];
    self.refreshTimer = nil;
    [self removeAllObservations];
}

- (void)refreshVisibleCells {
    NSArray *visibleCells = [self.tableView visibleCells];
    
    for (UITableViewCell *cell in visibleCells) {
        if([cell isKindOfClass:[PredictionCell class]])
            [(PredictionCell *)cell updateDates];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.pagingDatasource.objects.count)
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    
    return [PredictionCell heightForPrediction:[self.pagingDatasource.objects objectAtIndex:indexPath.row]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row >= self.pagingDatasource.objects.count)
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    Prediction *prediction = [self.pagingDatasource.objects objectAtIndex:indexPath.row];
    
    PredictionCell *cell = [PredictionCell predictionCellForTableView:tableView];
    
    [cell fillWithPrediction:prediction];
    cell.delegate = self;
    
    if (prediction.userId == self.appDelegate.currentUser.userId)
        cell.avatarImageView.image = [_imageLoader lazyLoadImage:self.appDelegate.currentUser.smallImageUrl onIndexPath:indexPath];
    else
        cell.avatarImageView.image = [_imageLoader lazyLoadImage:prediction.smallAvatarUrl onIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    
    if ([cell isKindOfClass:PredictionCell.class]) {
        PredictionCell *pCell = (PredictionCell *)cell;
        Prediction *prediction = [self.pagingDatasource.objects objectAtIndex:indexPath.row];
        if ([prediction.userName isEqualToString:@"takawiraa"]) {
            NSLog(@"%@", prediction);
        }
        if (prediction.userId == self.appDelegate.currentUser.userId)
            pCell.avatarImageView.image = [_imageLoader lazyLoadImage:self.appDelegate.currentUser.smallImageUrl onIndexPath:indexPath];
        else
            pCell.avatarImageView.image = [_imageLoader lazyLoadImage:prediction.smallAvatarUrl onIndexPath:indexPath];

    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.pagingDatasource.objects.count)
        return;

    Prediction *prediction = [self.pagingDatasource.objects objectAtIndex:indexPath.row];

    PredictionDetailsViewController *vc = [[PredictionDetailsViewController alloc] initWithPrediction:prediction];
    vc.delegate = self;
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)objectsAfterObject:(id)object completion:(void (^)(NSArray *, NSError *))completionHandler {
    NSInteger lastId = [(Prediction *)object predictionId];
    [[WebApi sharedInstance] getPredictionsAfter:lastId completion:completionHandler];
}

- (void)imageLoader:(ImageLoader *)loader finishedLoadingImage:(UIImage *)image forIndexPath:(NSIndexPath *)indexPath {
    PredictionCell *cell = (PredictionCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if (![cell isKindOfClass:PredictionCell.class])
        return;
    cell.avatarImageView.image = image;
}

- (void)predictionAgreed:(Prediction *)prediction inCell:(PredictionCell *) cell {
    
    [[WebApi sharedInstance] agreeWithPrediction:prediction.predictionId completion:^(Challenge *challenge, NSError *error) {
        if (!error) {
            prediction.challenge = challenge;
            [cell fillWithPrediction:prediction];
            [[WebApi sharedInstance] checkNewBadges];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"" message:@"Unable to agree at this time" delegate: nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles: nil];
            [alert show];
            
        }
    }];
}

- (void)predictionDisagreed:(Prediction *)prediction inCell:(PredictionCell *) cell {
    [[WebApi sharedInstance] disagreeWithPrediction:prediction.predictionId completion:^(Challenge *challenge, NSError *error) {
        if (!error) {
            prediction.challenge = challenge;
            [cell fillWithPrediction:prediction];
            [[WebApi sharedInstance] checkNewBadges];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"" message:@"Unable to disagree at this time" delegate: nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles: nil];
            [alert show];
        }
    }];
}

- (void)profileSelectedWithUserId:(NSInteger)userId inCell:(PredictionCell *)cell {
    if (userId == self.appDelegate.currentUser.userId) {
        ProfileViewController *vc = [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:[NSBundle mainBundle]];
        vc.leftButtonItemReturnsBack = YES;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        AnotherUsersProfileViewController *vc = [[AnotherUsersProfileViewController alloc] initWithUserId:userId];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)handleNewObjectNotification:(NSNotification *)notification {
    Prediction *prediction = [notification.userInfo objectForKey:NewPredictionNotificationKey];
    
    [self.pagingDatasource insertNewObject:prediction reload:YES];
}

- (void)updatePrediction:(Prediction *)prediction {
    
    NSInteger indexToExchange = NSNotFound;
    
    for (Prediction *oldPrediction in self.pagingDatasource.objects) {
        if (prediction.predictionId == oldPrediction.predictionId)
            indexToExchange = [self.pagingDatasource.objects indexOfObject:oldPrediction];
    }
    
    if (indexToExchange == NSNotFound)
        return;
    
    [self.pagingDatasource.objects replaceObjectAtIndex:indexToExchange withObject:prediction];
    [self.tableView reloadData];
}

@end
