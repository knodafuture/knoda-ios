//
//  NSNumber+Utils.m
//  KnodaIPhoneApp
//
//  Created by nick on 8/10/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "NSNumber+Utils.h"

@implementation NSNumber (Utils)

- (NSString *)ordinalString {
    
    NSString *ending;
    
    if (![self integerValue])
        return nil;
    
    NSInteger integer = self.integerValue;
    
    int ones = integer % 10;
    int tens = floor(integer / 10);
    tens = tens % 10;
    if(tens == 1){
        ending = @"th";
    } else {
        switch (ones) {
            case 1:
                ending = @"st";
                break;
            case 2:
                ending = @"nd";
                break;
            case 3:
                ending = @"rd";
                break;
            default:
                ending = @"th";
                break;
        }
    }
    return [NSString stringWithFormat:@"%ld%@", (long)integer, ending];
}

@end
