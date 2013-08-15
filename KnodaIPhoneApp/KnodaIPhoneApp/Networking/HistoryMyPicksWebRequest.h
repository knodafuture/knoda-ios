//
//  HistoryMyPicksWebRequest.h
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 8/14/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "BaseWebRequest.h"


@interface HistoryMyPicksWebRequest : BaseWebRequest

@property (nonatomic, strong) NSArray* predictions;

+ (NSInteger) limitByPage;
- (id) initWithLastCreatedDate: (NSDate*) lastCreatedDate;

@end
