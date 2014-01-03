//
//  SearchDatasource.m
//  KnodaIPhoneApp
//
//  Created by nick on 1/2/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "SearchDatasource.h"
#import "SearchSectionHeader.h"
#import "PredictionCell.h"
#import "NoSearchResultsCell.h" 
#import "UserCell.h"
#import "User.h"

@interface SearchDatasource ()
@property (assign, nonatomic) BOOL loading;
@end

@implementation SearchDatasource

- (id)initWithTableView:(UITableView *)tableView {
    self = [super initWithTableView:tableView];
    self.loading = YES;
    return self;
}

- (BOOL)canLoadNextPage {
    return NO;
}

- (NSArray *)objects {
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.loading)
        return 1;
    
    if (section == 0) {
        if (self.users.count > 0)
            return self.users.count;
        return 1;
    }
    else {
        if (self.predictions.count > 0)
            return self.predictions.count;
        return 1;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.loading)
        return [super numberOfSectionsInTableView:tableView];
    
    return 2;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.loading)
        return [super tableView:tableView viewForHeaderInSection:section];
    
    SearchSectionHeader *header = [[SearchSectionHeader alloc] init];
    
    if (section == 0)
        header.label.text = @"USERS";
    else
        header.label.text = @"PREDICTIONS";
    
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.loading)
        return [super tableView:tableView heightForHeaderInSection:section];
    
    return 20.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.loading)
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    
    if (indexPath.section == 0 && self.users.count == 0)
        return NoSearchResultsCellHeight;
    else if (indexPath.section == 0)
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    
    if (indexPath.section == 1 && self.predictions.count == 0)
        return NoSearchResultsCellHeight;
    
    return [PredictionCell heightForPrediction:[self.predictions objectAtIndex:indexPath.row]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.loading)
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        if (self.users.count == 0)
            return [NoSearchResultsCell noSearchResultsCellWithTitle:@"No users found" forTableView:self.tableView];
        
        User *user = [self.users objectAtIndex:indexPath.row];
        
        UserCell *cell = [UserCell userCellForTableView:tableView];
        cell.nameLabel.text = user.name;
        return cell;
    }
    
    if (self.predictions.count == 0)
        return [NoSearchResultsCell noSearchResultsCellWithTitle:@"No predictions found" forTableView:self.tableView];
    
    Prediction *prediction = [self.predictions objectAtIndex:indexPath.row];
    
    PredictionCell *cell = [PredictionCell predictionCellForTableView:tableView];
    
    [cell fillWithPrediction:prediction];
    
    return cell;
}

- (void)loadPage:(NSInteger)page completion:(void(^)(void))completion {
    
    self.loading = YES;
    
    id<SearchDatasourceDelegate> delegate = (id<SearchDatasourceDelegate>)self.delegate;
    
    if (![delegate respondsToSelector:@selector(getResultsCompletion:)]) {
        NSLog(@"Search datasource delegate not implemented");
        return;
    }
    
    [self.tableView reloadData];
    
    if (page != 0)
        return;
    
    [delegate getResultsCompletion:^(NSArray *users, NSArray *predictions, NSError *error) {

        self.users = [users mutableCopy];
        self.predictions = [predictions mutableCopy];
        self.loading = NO;
        
        if (completion)
            completion();
        
    }];
    
}
@end
