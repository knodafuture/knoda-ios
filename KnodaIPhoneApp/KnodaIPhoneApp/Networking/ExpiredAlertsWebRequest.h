//
//  ExpiredAlertsWebRequest.h
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 8/20/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "BaseWebRequest.h"

@interface ExpiredAlertsWebRequest : BaseWebRequest

@property (nonatomic, strong) NSArray* predictions;

@end
