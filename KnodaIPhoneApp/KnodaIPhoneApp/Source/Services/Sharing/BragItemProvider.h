//
//  BragItemProvider.h
//  KnodaIPhoneApp
//
//  Created by nick on 7/2/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Prediction;

@interface BragItemProvider : UIActivityItemProvider <UIActivityItemSource>

- (id)initWithPrediction:(Prediction *)prediction;

@end
