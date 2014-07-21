//
//  PredictionDetailsViewController.h
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 8/6/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//



@class Prediction;

@protocol PredictionDetailsDelegate <NSObject>

- (void)updatePrediction:(Prediction *)prediction;

@end

@interface PredictionDetailsViewController : UIViewController

@property (weak, nonatomic) id<PredictionDetailsDelegate> delegate;
@property (assign, nonatomic) BOOL shouldNotOpenCategory;
@property (assign, nonatomic) BOOL shouldNotOpenProfile;

- (id)initWithPrediction:(Prediction *)prediction;

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

@end

