//
//  TallyDatasource.m
//  KnodaIPhoneApp
//
//  Created by nick on 12/7/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "TallyDatasource.h"
#import "PredictorCell.h"
#import "PredictorHeaderCell.h"

@interface TallyDatasource () {
    NSArray *_agreedUsers;
    NSArray *_disagreedUsers;
}

@end

@implementation TallyDatasource

- (BOOL)canLoadNextPage {
    return NO;
}

- (NSArray *)objects {
    if (_agreedUsers.count > _disagreedUsers.count)
        return _agreedUsers;
    else
        return _disagreedUsers;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.objects.count == 0)
        return [super tableView:tableView numberOfRowsInSection:section];
    
    return [super tableView:tableView numberOfRowsInSection:section] + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.objects.count == 0)
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    
    if (indexPath.row >= self.objects.count + 1)
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    
    if (indexPath.row == 0)
        return PredictorHeaderCellHeight;
    
    return PredictorCellHeight;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.objects.count == 0)
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if (indexPath.row >= self.objects.count + 1)
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];

    if (indexPath.row == 0) {
        PredictorHeaderCell *cell = [PredictorHeaderCell predictorHeaderCellForTableView:tableView];
        cell.leftLabel.text = [NSString stringWithFormat:@"Agree %d", _agreedUsers.count];
        cell.rightLabel.text = [NSString stringWithFormat:@"Disagree %d", _disagreedUsers.count];
        return cell;
    }
    
    
    PredictorCell *cell = [PredictorCell predictorCellForTableView:tableView];
    
    int idx = indexPath.row - 1;
    cell.agreedUserName.text    = _agreedUsers.count > idx ? _agreedUsers[idx] : @"";
    cell.disagreedUserName.text = _disagreedUsers.count > idx ? _disagreedUsers [idx] : @"";
    
    return cell;

}

- (void)loadPage:(NSInteger)page completion:(void(^)(void))completion {
    
    id<TallyDatasourceDelegate> delegate = (id<TallyDatasourceDelegate>)self.delegate;
    
    if (![delegate respondsToSelector:@selector(requestTallyCompletion:)]) {
        NSLog(@"Tally datasource delegate not implemented");
        return;
    }
    
    if (page != 0)
        return;
    
    [delegate requestTallyCompletion:^(NSArray *agreedUsers, NSArray *disagreedUsers, NSError *error) {
        if (error || (agreedUsers.count == 0 && disagreedUsers.count == 0)) {
            if ([delegate respondsToSelector:@selector(noObjectsRetrievedInPagingDatasource:)]) {
                [delegate noObjectsRetrievedInPagingDatasource:self];
            }
            return;
        }
        
        _agreedUsers = agreedUsers;
        _disagreedUsers = disagreedUsers;
        
        
        if (completion)
            completion();
        
    }];
    
}


@end
