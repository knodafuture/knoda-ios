//
//  CategoryPredictionsViewController.h
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 22.08.13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "HomeViewController.h"

@interface CategoryPredictionsViewController : HomeViewController

@property (nonatomic) NSString *category;

- (IBAction)backButtonPressed:(UIButton *)sender;

@end
