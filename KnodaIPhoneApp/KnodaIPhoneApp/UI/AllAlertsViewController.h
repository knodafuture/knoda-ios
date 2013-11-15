//
//  AllAlertsViewController.h
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/25/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "BaseRequestingViewController.h"
#import "PredictionCell.h"

@interface AllAlertsViewController : BaseRequestingViewController <UITableViewDataSource, UITableViewDelegate, PredictionCellDelegate>
@property (nonatomic, strong) IBOutlet UITableView* tableView;
@property (weak, nonatomic)   IBOutlet UIView *noContentView;
@end
