//
//  LoginWebRequest.h
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/11/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "BaseWebRequest.h"

@interface PredictionsWebRequest : BaseWebRequest

@property (nonatomic, readonly) NSArray* predictions;

- (id) initWithPageNumber: (NSInteger) page;

@end
