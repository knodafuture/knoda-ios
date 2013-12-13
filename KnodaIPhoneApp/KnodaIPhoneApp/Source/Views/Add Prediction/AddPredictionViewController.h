//
//  AddPredictionViewController.h
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 8/5/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AddPredictionViewController;
@class Prediction;
@protocol AddPredictionViewControllerDelegate <NSObject>

- (void)addPredictionViewController:(AddPredictionViewController *)viewController didCreatePrediction:(Prediction *)prediction;

@end


@interface AddPredictionViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate>

@property (nonatomic, weak) id<AddPredictionViewControllerDelegate> delegate;


@end
