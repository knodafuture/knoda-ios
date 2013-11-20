//
//  AddPredictionRequest.h
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/12/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "BaseWebRequest.h"

@interface AddPredictionRequest : BaseWebRequest

- (id)initWithBody:(NSString *)body expirationDate:(NSDate *)date resolutionDate:(NSDate *)resolutionDate category:(NSString *)category;

@end
