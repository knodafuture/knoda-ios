//
//  ChellangeByPredictionWebRequest.h
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 8/13/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "BaseWebRequest.h"
#import "Challenge.h"


@interface ChellangeByPredictionWebRequest : BaseWebRequest

@property (nonatomic, strong) Challenge* chellange;

- (id) initWithPredictionID: (NSInteger) predictionID;

@end
