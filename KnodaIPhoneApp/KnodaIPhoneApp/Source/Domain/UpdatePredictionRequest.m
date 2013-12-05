//
//  UpdatePredictionRequest.m
//  KnodaIPhoneApp
//
//  Created by nick on 12/6/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "UpdatePredictionRequest.h"
#import "NSDate+Utils.h"

@implementation UpdatePredictionRequest

- (NSDictionary *)parametersDictionary {
    NSDateComponents *dc = [self.resolutionDate gmtDateComponents];
    return @{@"prediction[resolution_date(1i)]" : @(dc.year),
                             @"prediction[resolution_date(2i)]" : @(dc.month),
                             @"prediction[resolution_date(3i)]" : @(dc.day),
                             @"prediction[resolution_date(4i)]" : @(dc.hour),
                             @"prediction[resolution_date(5i)]" : @(dc.minute)};
}
@end
