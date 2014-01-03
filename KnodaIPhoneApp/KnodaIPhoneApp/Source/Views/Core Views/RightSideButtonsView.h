//
//  RightSideButtonsView.h
//  KnodaIPhoneApp
//
//  Created by nick on 1/2/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RightSideButtonsView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *searchImageView;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIImageView *addPredictionImageView;
@property (weak, nonatomic) IBOutlet UIButton *addPredictionButton;

- (void)setAddPredictionTarget:(id)target action:(SEL)action;
- (void)setSearchTarget:(id)target action:(SEL)action;

- (void)setSearchButtonHidden:(BOOL)hidden;

@end
