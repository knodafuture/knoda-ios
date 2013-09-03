//
//  ChildViewController.h
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 02.09.13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChildControllerDataSource;

@interface ChildViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView* tableView;
@property (weak, nonatomic)   IBOutlet UIView *noContentView;

@property (nonatomic, weak) id<ChildControllerDataSource> childDataSource;

@property (nonatomic, strong) NSMutableArray* predictions;

- (NSInteger)limitByPage;

@end
