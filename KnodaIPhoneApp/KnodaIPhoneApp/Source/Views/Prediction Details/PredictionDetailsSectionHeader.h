//
//  PredictionDetailsSectionHeader.h
//  KnodaIPhoneApp
//
//  Created by Nick R on 11/15/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Prediction;
const extern CGFloat PredictionDetailsSectionHeaderHeight;

@interface PredictionDetailsSectionHeader : UIView

+ (PredictionDetailsSectionHeader *)sectionHeaderWithOwner:(id)owner forPrediction:(Prediction *)prediction;
@end
