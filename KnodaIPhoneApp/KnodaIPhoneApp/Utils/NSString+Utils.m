//
//  NSString+Utils.m
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 20.08.13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "NSString+Utils.h"

@implementation NSString (Utils)

- (NSString *)safeFileName {
    static NSCharacterSet* _illegalFileNameCharacters = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _illegalFileNameCharacters = [NSCharacterSet characterSetWithCharactersInString:@"/\\?%*|\"<>"];
    });
    
    return [[self componentsSeparatedByCharactersInSet:_illegalFileNameCharacters] componentsJoinedByString:@""];
}

@end
