//
//  PredictionDetailsViewController.h
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 8/6/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "BaseRequestingViewController.h"

#import "Prediction.h"

@class Prediction;

@protocol AddPredictionViewControllerDelegate;
@protocol PredictionDetailsDelegate;

@interface PredictionDetailsViewController : BaseRequestingViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) Prediction *prediction;

@property (nonatomic, weak) id<AddPredictionViewControllerDelegate> addPredictionDelegate;
@property (nonatomic, weak) id<PredictionDetailsDelegate> delegate;

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

@protocol PredictionDetailsDelegate <NSObject>

- (void)updatePrediction:(Prediction *)prediction;

@end