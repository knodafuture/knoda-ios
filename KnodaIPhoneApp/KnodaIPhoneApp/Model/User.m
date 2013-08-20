//
//  User.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/9/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "User.h"

@implementation User

- (id)initWithDictionary:(NSDictionary *)dictionary {
    if(self = [super init]) {
        self.name  = [dictionary objectForKey: @"username"];
        self.email = [dictionary objectForKey: @"email"];
    }
    return self;
}

@end
