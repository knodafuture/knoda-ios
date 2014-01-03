//
//  SearchDatasource.h
//  KnodaIPhoneApp
//
//  Created by nick on 1/2/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "PagingDatasource.h"

@protocol SearchDatasourceDelegate <NSObject, PagingDatasourceDelegate>

- (void)getResultsCompletion:(void(^)(NSArray *users, NSArray *predictions, NSError *error))completionHandler;

@end

@interface SearchDatasource : PagingDatasource
@property (strong, nonatomic) NSMutableArray *users;
@property (strong, nonatomic) NSMutableArray *predictions;
@end
