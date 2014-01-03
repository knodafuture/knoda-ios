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
#import "TallyUser.h"

@interface TallyDatasource () {
    NSMutableArray *_agreedUsers;
    NSMutableArray *_disagreedUsers;
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
    
    [cell setAgreedUser:[self userAtIndex:idx inArray:_agreedUsers] andDisagreedUser:[self userAtIndex:idx inArray:_disagreedUsers]];
    
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
        
        _agreedUsers = [agreedUsers mutableCopy];
        _disagreedUsers = [disagreedUsers mutableCopy];
        
        
        if (completion)
            completion();
        
    }];
    
}

- (void)updateTallyForUser:(NSString *)username agree:(BOOL)agree {
    if (agree) {
        if ([_agreedUsers containsObject:username])
            return;
        if ([_disagreedUsers containsObject:username])
            [_disagreedUsers removeObject:username];
        [_agreedUsers addObject:username];
    } else {
        if ([_disagreedUsers containsObject:username])
            return;
        if ([_agreedUsers containsObject:username])
            [_agreedUsers removeObject:username];
        [_disagreedUsers addObject:username];
    }
}


- (TallyUser *)userAtIndex:(NSInteger)index inArray:(NSArray *)array {
    if (index >= array.count)
        return nil;
    
    return array[index];
}

- (NSString *)nameForUserAtIndex:(NSInteger)index inArray:(NSArray *)array {
    if (index >= array.count)
        return @"";
    
    TallyUser *user = array[index];
    
    return user.username;
        
}

@end
