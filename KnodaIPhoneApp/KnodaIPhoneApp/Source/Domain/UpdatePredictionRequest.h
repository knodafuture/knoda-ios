//
//  UpdatePredictionRequest.h
//  KnodaIPhoneApp
//
//  Created by nick on 12/6/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "WebObject.h"

@interface UpdatePredictionRequest : WebObject
@property (assign, nonatomic) NSInteger predictionId;
@property (strong, nonatomic) NSDate *resolutionDate;
@end
