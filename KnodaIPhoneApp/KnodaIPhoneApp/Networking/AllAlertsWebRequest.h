//
//  AllAlertsWebRequest.h
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 8/19/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "BaseWebRequest.h"

@interface AllAlertsWebRequest : BaseWebRequest

@property (nonatomic, strong) NSArray* predictions;

@end
