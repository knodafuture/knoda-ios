//
//  BaseTableViewController.h
//  KnodaIPhoneApp
//
//  Created by Nick R on 11/22/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageLoader.h"
#import "PagingDatasource.h"

@interface BaseTableViewController : UITableViewController <ImageLoaderDelegate, PagingDatasourceDelegate> {
    ImageLoader *_imageLoader;
}

@property (strong, nonatomic) PagingDatasource *pagingDatasource;
@property (assign, nonatomic) BOOL hasAppeared;

- (void)refresh;
- (void)beginRefreshing;
- (void)endRefreshing;
- (void)showNoContent:(UITableViewCell *)noContentCell;
- (void)restoreContent;

- (void)handleNewObjectNotification:(NSNotification *)notification;

- (void)appeared;
- (void)disappeared;

@end
