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
@class Group;
@protocol AddPredictionViewControllerDelegate <NSObject>

- (void)addPredictionViewController:(AddPredictionViewController *)viewController didCreatePrediction:(Prediction *)prediction;

@end


@interface AddPredictionViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate>

- (id)initWithActiveGroup:(Group *)group;

@property (nonatomic, weak) id<AddPredictionViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *expirationBar;


@end
