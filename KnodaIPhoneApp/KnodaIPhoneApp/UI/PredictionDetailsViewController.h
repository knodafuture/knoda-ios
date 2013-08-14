//
//  PredictionDetailsViewController.h
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 8/6/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Prediction.h"

@class Prediction;

@interface PredictionDetailsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) Prediction *prediction;

- (IBAction)backButtonPressed:(UIButton *)sender;
- (IBAction)bsButtonTapped:(UIButton *)sender;
- (IBAction)agreeButtonTapped:(UIButton *)sender;
- (IBAction)disagreeButtonTapped:(UIButton *)sender;
- (IBAction)yesButtonTapped:(UIButton *)sender;
- (IBAction)noButtonTapped:(UIButton *)sender;
- (IBAction)unfinishButtonTapped:(UIButton *)sender;

@end
