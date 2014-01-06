//
//  TallyDatasource.h
//  KnodaIPhoneApp
//
//  Created by nick on 12/7/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "PagingDatasource.h"

@class TallyUser;
@protocol TallyDatasourceDelegate <NSObject, PagingDatasourceDelegate>

- (void)requestTallyCompletion:(void(^)(NSArray *agreedUsers, NSArray *disagreedUsers, NSError *error))completionHandler;

@end

@interface TallyDatasource : PagingDatasource

- (void)updateTallyForUser:(TallyUser *)user agree:(BOOL)agree;

@end
