//
//  CategoryPredictionsViewController.h
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 22.08.13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "PredictionsViewController.h"

@interface CategoryPredictionsViewController : PredictionsViewController

@property (nonatomic, assign) BOOL shouldNotOpenProfile;

- (id)initWithCategory:(NSString *)category;
@end
