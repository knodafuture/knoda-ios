//
//  AddPredictionViewController.h
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 8/5/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol AddPredictionViewControllerDelegate <NSObject>

- (void) predictinMade;

@end


@interface AddPredictionViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, weak) id<AddPredictionViewControllerDelegate> delegate;

@end
