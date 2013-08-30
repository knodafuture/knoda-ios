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

@protocol AddPredictionViewControllerDelegate;

@interface PredictionDetailsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) Prediction *prediction;

@property (nonatomic, weak) id<AddPredictionViewControllerDelegate> addPredictionDelegate;

@property (nonatomic, assign) BOOL shouldNotOpenCategory;

- (IBAction)backButtonPressed:(UIButton *)sender;
- (IBAction)bsButtonTapped:(UIButton *)sender;
- (IBAction)agreeButtonTapped:(UIButton *)sender;
- (IBAction)disagreeButtonTapped:(UIButton *)sender;
- (IBAction)yesButtonTapped:(UIButton *)sender;
- (IBAction)noButtonTapped:(UIButton *)sender;
- (IBAction)unfinishButtonTapped:(UIButton *)sender;
- (IBAction)hidePicker:(UIBarButtonItem *)sender;
- (IBAction)unfinishPrediction:(UIBarButtonItem *)sender;
- (IBAction)categoryButtonTapped:(UIButton *)sender;

@end
