//
//  PredictionUsersWebRequest.h
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 14.08.13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "BaseWebRequest.h"

@interface PredictionUsersWebRequest : BaseWebRequest

@property (nonatomic) NSArray *users;

- (id)initWithPredictionId:(NSInteger)predictionId forAgreedUsers:(BOOL)isForAgreed;

@end
