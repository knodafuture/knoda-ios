//
//  NSData+Utils.m
//  KnodaIPhoneApp
//
//  Created by nick on 12/5/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "NSData+Utils.h"

@implementation NSData (Utils)

- (id)jsonObject {
    NSError *serializationError;
    
    id obj = [NSJSONSerialization JSONObjectWithData:self options:kNilOptions error:&serializationError];
    
    if (serializationError || !obj)
        return nil;
    
    return obj;
    
}

@end
