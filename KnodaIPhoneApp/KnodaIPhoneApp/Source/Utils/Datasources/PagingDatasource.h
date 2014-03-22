//
//  PagingDatasource.h
//  KnodaIPhoneApp
//
//  Created by nick on 12/7/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PagingDatasource;
@protocol PagingDatasourceDelegate <NSObject>

- (void)objectsAfterObject:(id)object completion:(void(^)(NSArray *objectsToAdd, NSError *error))completionHandler;
- (void)pagingDatasource:(PagingDatasource *)pagingDatasource willDisplayObjects:(NSArray *)objects;
- (void)noObjectsRetrievedInPagingDatasource:(PagingDatasource *)pagingDatasource;
@end

@interface PagingDatasource : NSObject <UITableViewDataSource, UITableViewDelegate>
@property (assign, nonatomic) NSInteger section;
@property (strong, nonatomic) NSMutableArray *objects;
@property (assign, nonatomic) NSInteger currentPage;
@property (weak, nonatomic) id<PagingDatasourceDelegate> delegate;
@property (weak, nonatomic) UITableView *tableView;
@property (assign, nonatomic) BOOL pageLoading;

- (id)initWithTableView:(UITableView *)tableView;
- (void)loadPage:(NSInteger)page completion:(void(^)(void))completion;
- (BOOL)canLoadNextPage;

- (void)insertNewObject:(id)object atIndex:(NSInteger)index reload:(BOOL)reload;

@end
