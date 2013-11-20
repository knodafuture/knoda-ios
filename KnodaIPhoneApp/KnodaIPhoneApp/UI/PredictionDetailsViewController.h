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

@protocol PredictionDetailsDelegate;

@interface PredictionDetailsViewController : BaseRequestingViewController

@property (nonatomic, strong) Prediction *prediction;

@property (nonatomic, weak) id<PredictionDetailsDelegate> delegate;

@property (nonatomic, assign) BOOL shouldNotOpenCategory;
@property (nonatomic, assign) BOOL shouldNotOpenProfile;

- (IBAction)bsButtonTapped:(UIButton *)sender;
- (IBAction)agreeButtonTapped:(UIButton *)sender;
- (IBAction)disagreeButtonTapped:(UIButton *)sender;
- (IBAction)yesButtonTapped:(UIButton *)sender;
- (IBAction)noButtonTapped:(UIButton *)sender;
- (IBAction)categoryButtonTapped:(UIButton *)sender;
- (IBAction)remindMeTapped:(id)sender;
- (IBAction)showComments:(id)sender;
- (IBAction)showOtherUsers:(id)sender;

- (IBAction)share:(id)sender;


@property (weak, nonatomic) IBOutlet UIView *pickerContainerView;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

- (IBAction)cancelPickerView:(id)sender;
- (IBAction)donePickerView:(id)sender;


@end

@protocol PredictionDetailsDelegate <NSObject>

- (void)updatePrediction:(Prediction *)prediction;

@end