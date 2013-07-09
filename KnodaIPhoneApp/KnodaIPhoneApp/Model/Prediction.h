//
//  Prediction.h
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/9/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Prediction : NSObject

@property (nonatomic, strong) NSString* ID;
@property (nonatomic, strong) NSDate* expirationDate;
@property (nonatomic, strong) NSArray* topics;

@end
