//
//  HistoryMyPredictionsRequest.h
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 8/14/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "BaseWebRequest.h"

@interface HistoryMyPredictionsRequest : BaseWebRequest

@property (nonatomic, strong) NSArray* predictions;

- (id) initWithLastID: (NSInteger) lastID;

@end
