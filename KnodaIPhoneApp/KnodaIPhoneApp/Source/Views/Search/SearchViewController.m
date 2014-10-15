//
//  SearchViewController.m
//  KnodaIPhoneApp
//
//  Created by nick on 1/2/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchBar.h"   
#import "WebApi.h"  
#import "CategoryPredictionsViewController.h"
#import "SearchDatasource.h"
#import "CategoriesDatasource.h"
#import "PredictionCell.h"
#import "AnotherUsersProfileViewController.h"
#import "ProfileViewController.h"
#import "UserManager.h"
#import "PredictionDetailsViewController.h"
#import "UserCell.h"
#import "FollowersTableViewCell.h"
#import "Follower.h"
#import "LoadingView.h"

@interface SearchViewController () <SearchBarDelegate, SearchDatasourceDelegate, PredictionDetailsDelegate, UserCellDelegate>
@property (strong, nonatomic) SearchBar *searchBar;
@property (strong, nonatomic) SearchDatasource *searchDatasource;
@property (strong, nonatomic) CategoriesDatasource *categoriesDatasource;
@property (assign, nonatomic) BOOL shouldBeginEditingSearchText;
@property (strong, nonatomic) NSString *searchTerm;
@end

@implementation SearchViewController

- (void)viewDidLoad {
    
    self.pagingDatasource = self.categoriesDatasource = [[CategoriesDatasource alloc] initWithTableView:self.tableView];
    [super viewDidLoad];

    self.shouldBeginEditingSearchText = YES;
    
    self.searchBar = [[SearchBar alloc] init];
    self.searchBar.delegate = self;
    self.searchBar.backgroundColor = [UIColor colorFromHex:@"77BC1F"];
    
    

    CGRect frame = self.searchBar.frame;
    frame.origin.x = self.view.frame.size.width;
    self.searchBar.frame = frame;
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backButtonWithTarget:self action:@selector(back)];
    
    self.refreshControl = nil;
    
    self.searchDatasource = [[SearchDatasource alloc] initWithTableView:self.tableView];
    self.searchDatasource.delegate = self;
    
    if (self.searchTerm) {
        
        self.searchBar.textField.text = self.searchTerm;
        [self searchBar:self.searchBar didSearchForText:self.searchTerm];
    }

    
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.shouldBeginEditingSearchText)
        [self.searchBar.textField becomeFirstResponder];
    self.shouldBeginEditingSearchText = NO;
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:self.searchBar];

    NSTimeInterval duration;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
        duration = 0.35;
    else
        duration = 0.4;
    
    CGRect frame = self.searchBar.frame;
    frame.origin.x = 30;
    
    if (animated)
        [UIView animateWithDuration:duration animations:^{
            self.searchBar.frame = frame;
        }];
    else
        self.searchBar.frame = frame;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self removeSearchBar];
    
    if ([self.delegate respondsToSelector:@selector(searchViewControllerDidFinish:)])
        [self.delegate searchViewControllerDidFinish:self];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)removeSearchBar {
    [self.searchBar removeFromSuperview];

}

- (void)searchForTerm:(NSString *)term {
    self.searchTerm = term;
}
- (void)searchBar:(SearchBar *)searchBar didSearchForText:(NSString *)searchText {
    self.pagingDatasource = self.searchDatasource;
    
    [self.pagingDatasource loadPage:0 completion:^{
        [self.tableView reloadData];
    }];
}

- (void)searchBarDidClearText:(SearchBar *)searchBar {
    self.pagingDatasource = self.categoriesDatasource;
    
    [self.pagingDatasource loadPage:0 completion:^{
        [self.tableView reloadData];
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell isKindOfClass:PredictionCell.class]) {
        PredictionCell *pCell = (PredictionCell *)cell;;
        if (pCell.prediction.userId == [UserManager sharedInstance].user.userId)
            pCell.avatarImageView.image = [_imageLoader lazyLoadImage:[UserManager sharedInstance].user.avatar.small onIndexPath:indexPath];
        else
            pCell.avatarImageView.image = [_imageLoader lazyLoadImage:pCell.prediction.userAvatar.small onIndexPath:indexPath];
        
    }
    
    if ([cell isKindOfClass:UserCell.class]) {
        UserCell *uCell = (UserCell *)cell;
        uCell.avatarImageView.image = [_imageLoader lazyLoadImage:uCell.user.avatar.small onIndexPath:indexPath];
        uCell.delegate = self;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.pagingDatasource == self.categoriesDatasource)
        [self categorySelectedAtIndexPath:indexPath];
    else
        [self searchResultSelectedAtIndexPath:indexPath];

}

- (void)categorySelectedAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.pagingDatasource.objects.count)
        return;
    
    Tag *topic = [self.pagingDatasource.objects objectAtIndex:indexPath.row];
    
    CategoryPredictionsViewController *vc = [[CategoryPredictionsViewController alloc] initWithCategory:topic.name];
    
    [self.navigationController pushViewController:vc animated:YES];
    
    [self removeSearchBar];
}

- (void)searchResultSelectedAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        if (indexPath.row >= self.searchDatasource.users.count)
            return;
        
        User *user = [self.searchDatasource.users objectAtIndex:indexPath.row];
        
        [self profileSelectedWithUserId:user.userId inCell:nil];
        return;
    }
    
    if (indexPath.row >= self.searchDatasource.predictions.count)
        return;
    
    Prediction *prediction = [self.searchDatasource.predictions objectAtIndex:indexPath.row];
    
    PredictionDetailsViewController *vc = [[PredictionDetailsViewController alloc] initWithPrediction:prediction];
    
    vc.delegate = self;
    
    [self.navigationController pushViewController:vc animated:YES];
    
    [self removeSearchBar];
    
}


- (void)objectsAfterObject:(id)object completion:(void (^)(NSArray *, NSError *))completionHandler {
    [[WebApi sharedInstance] getCategoriesCompletion:completionHandler];
}


- (void)getResultsCompletion:(void (^)(NSArray *, NSArray *, NSError *))completionHandler {
    [[WebApi sharedInstance] searchForUsers:self.searchBar.textField.text completion:^(NSArray *users, NSError *error) {
        if (error) {
            completionHandler(nil, nil, error);
            return;
        }
        
        [[WebApi sharedInstance] searchForPredictions:self.searchBar.textField.text completion:^(NSArray *predictions, NSError *error) {
            completionHandler(users, predictions, error);
        }];
    }];
}

- (void)profileSelectedWithUserId:(NSInteger)userId inCell:(PredictionCell *)cell {
    if (userId == [UserManager sharedInstance].user.userId) {
//        ProfileViewController *vc = [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:[NSBundle mainBundle]];
//        vc.leftButtonItemReturnsBack = YES;
//        [self.navigationController pushViewController:vc animated:YES];
//        [self removeSearchBar];
    } else {
        AnotherUsersProfileViewController *vc = [[AnotherUsersProfileViewController alloc] initWithUserId:userId];
        [self.navigationController pushViewController:vc animated:YES];
        [self removeSearchBar];
    }
}

- (void)updatePrediction:(Prediction *)prediction {
    
    NSInteger indexToExchange = NSNotFound;
    
    for (Prediction *oldPrediction in self.searchDatasource.predictions) {
        if (prediction.predictionId == oldPrediction.predictionId)
            indexToExchange = [self.searchDatasource.predictions indexOfObject:oldPrediction];
    }
    
    if (indexToExchange == NSNotFound)
        return;
    
    [self.searchDatasource.predictions replaceObjectAtIndex:indexToExchange withObject:prediction];
    [self.tableView reloadData];
}

- (void)imageLoader:(ImageLoader *)loader finishedLoadingImage:(UIImage *)image forIndexPath:(NSIndexPath *)indexPath {

    if (self.pagingDatasource == self.categoriesDatasource)
        return;
    
    if (indexPath.section == 0) {
        UserCell *cell = (UserCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        if (![cell isKindOfClass:UserCell.class])
            return;
        cell.avatarImageView.image = image;
    }
    
    PredictionCell *cell = (PredictionCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    if (![cell isKindOfClass:PredictionCell.class])
        return;
    cell.avatarImageView.image = image;
}

- (void)didFollowInCell:(UserCell *)cell onIndexPath:(NSIndexPath *)indexPath {
    
    User *user = [self.searchDatasource.users objectAtIndex:indexPath.row];
    
    [[LoadingView sharedInstance] show];
    
    if (user.followingId) {
        [[WebApi sharedInstance] unfollowUser:user.followingId.integerValue completion:^(NSError *error) {
            cell.following = NO;
            user.followingId = nil;
            [[LoadingView sharedInstance] hide];
        }];
    } else {
        Follower *follower = [[Follower alloc] init];
        follower.leaderId = @(user.userId);
        [[WebApi sharedInstance] followUsers:@[follower] completion:^(NSArray *results, NSError *error) {
            cell.following = YES;
            user.followingId = [results firstObject][@"id"];
            [[LoadingView sharedInstance] hide];
        }];
    }
}
@end
