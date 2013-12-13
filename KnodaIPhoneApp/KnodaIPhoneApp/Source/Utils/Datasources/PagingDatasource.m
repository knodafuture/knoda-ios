//
//  PagingDatasource.m
//  KnodaIPhoneApp
//
//  Created by nick on 12/7/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "PagingDatasource.h"
#import "LoadingCell.h"
#import "WebApi.h"

@interface PagingDatasource ()

@property (assign, nonatomic) BOOL pageLoading;
@property (weak, nonatomic) UITableView *tableView;
@property (assign, nonatomic) NSInteger section;
@end

@implementation PagingDatasource

- (id)initWithTableView:(UITableView *)tableView {
    self = [super init];
    self.currentPage = 0;
    self.objects = [NSMutableArray array];
    self.pageLoading = NO;
    self.tableView = tableView;
    return self;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return loadingCellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    self.section = section;
    
    if (self.objects.count == 0)
        return 1;
    
    if ([self canLoadNextPage])
        return self.objects.count + 1;
    
    return self.objects.count;
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (![self canLoadNextPage])
        return;
    
    if (indexPath.row != self.objects.count || self.pageLoading || self.objects.count == 0)
        return;
    
    self.pageLoading = YES;
    
    [self loadPage:self.currentPage + 1 completion:^{
        NSInteger beginIndex = (self.currentPage + 1) * PageLimit;
        NSInteger endIndex = self.objects.count - 1;
        
        if ([self canLoadNextPage])
            endIndex++;
        
        NSIndexSet *indexesToInsert = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(beginIndex, endIndex  - beginIndex)];
        
        NSMutableArray *mutableIndexes = [[NSMutableArray alloc] initWithCapacity:indexesToInsert.count];
        
        [indexesToInsert enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            NSIndexPath *path = [NSIndexPath indexPathForRow:idx inSection:self.section];
            [mutableIndexes addObject:path];
        }];
        
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:mutableIndexes withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
        
        self.currentPage = self.currentPage + 1;
        self.pageLoading = NO;
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [LoadingCell loadingCellForTableView:tableView];
}

- (void)loadPage:(NSInteger)page completion:(void(^)(void))completion {
    
    id lastObject;
    if (page != 0)
        lastObject = [self.objects lastObject];
    
    [self.delegate objectsAfterObject:lastObject completion:^(NSArray *objectsToAdd, NSError *error) {
        
        if (page == 0 && objectsToAdd.count == 0) {
            if ([self.delegate respondsToSelector:@selector(noObjectsRetrievedInPagingDatasource:)])
                [self.delegate noObjectsRetrievedInPagingDatasource:self];
            completion();
            return ;
        }
    
        if (error || !objectsToAdd || objectsToAdd.count == 0)
            return;
    
        if (page == 0)
            self.objects = [objectsToAdd mutableCopy];
            
        else {
            [self.objects addObjectsFromArray:objectsToAdd];
        }
        
        if (self.objects.count > 0) {
            if ([self.delegate respondsToSelector:@selector(pagingDatasource:willDisplayObjects:)])
                [self.delegate pagingDatasource:self willDisplayObjects:self.objects];
        }
        
        if (completion)
            completion();
    }];
}

- (void)insertNewObject:(id)object {
    if (!object)
        return;
    
    [self.objects insertObject:object atIndex:0];
    
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:self.section]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

- (BOOL)canLoadNextPage {
    
    if (self.objects.count == 0)
        return 0;
    
    CGFloat div = (self.currentPage * PageLimit) / (CGFloat)PageLimit;
    
    if (div >= ceil(div))
        return YES;
    
    return NO;
}

@end
