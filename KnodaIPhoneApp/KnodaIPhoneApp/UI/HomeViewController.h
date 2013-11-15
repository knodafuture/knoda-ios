//
//  HomeViewController.h
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/24/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "AddPredictionViewController.h"
#import "PredictionCell.h"
#import "PredictionDetailsViewController.h"

@interface HomeViewController : UITableViewController <AddPredictionViewControllerDelegate, PredictionCellDelegate, PredictionDetailsDelegate>

@end
