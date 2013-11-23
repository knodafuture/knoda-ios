//
//  BaseTableViewController.m
//  KnodaIPhoneApp
//
//  Created by Nick R on 11/22/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "BaseTableViewController.h"
#import "NoContentCell.h"

@interface EmptyDelegate : NSObject <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) NoContentCell *cell;
@end


@implementation EmptyDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.cell.frame.size.height;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.cell;
}
@end




@interface BaseTableViewController ()
@property (strong, nonatomic) EmptyDelegate *emptyDelegate;

@end

@implementation BaseTableViewController


- (void)showNoContent:(NoContentCell *)noContentCell {
    self.emptyDelegate = [[EmptyDelegate alloc] init];
    self.emptyDelegate.cell = noContentCell;
    
    self.tableView.delegate = self.emptyDelegate;
    self.tableView.dataSource = self.emptyDelegate;
    
    [self.tableView reloadData];
    
    
}

- (void)restoreContent {
    
    self.emptyDelegate = nil;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView reloadData];
}


@end
