//
//  AddPredictionViewController.h
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 8/5/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AddPredictionViewController;

@protocol AddPredictionViewControllerDelegate <NSObject>

- (void)predictionWasMadeInController:(AddPredictionViewController *)vc;

@end


@interface AddPredictionViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate>

@property (nonatomic, weak) id<AddPredictionViewControllerDelegate> delegate;

- (IBAction)expirationPickerValueChanged:(id)sender;
- (IBAction)resolutionPickerValueChanged:(id)sender;
@end
