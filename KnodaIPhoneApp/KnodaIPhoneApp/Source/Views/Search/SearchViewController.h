//
//  SearchViewController.h
//  KnodaIPhoneApp
//
//  Created by nick on 1/2/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "BaseTableViewController.h"

@class SearchViewController;

@protocol SearchViewControllerDelegate <NSObject>

- (void)searchViewControllerDidFinish:(SearchViewController *)searchViewController;

@end


@interface SearchViewController : BaseTableViewController

@property (weak, nonatomic) id<SearchViewControllerDelegate> delegate;


@end
