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
        self.points = [[dictionary objectForKey: @"points"]integerValue];
        self.notificationsOn = [[dictionary objectForKey: @"points"]boolValue];
        self.won = [[dictionary objectForKey: @"won"]integerValue];
        self.lost = [[dictionary objectForKey: @"lost"]integerValue];
        self.winningPercentage = [NSNumber numberWithFloat:[[dictionary objectForKey: @"winning_percentage"]floatValue]];
        self.streak = [dictionary objectForKey: @"streak"];
        self.totalPredictions = [[dictionary objectForKey: @"total_predictions"]integerValue];
        self.alerts = [[dictionary objectForKey: @"alerts"]integerValue];
        self.badges = [[dictionary objectForKey: @"badges"]integerValue];
    }
    return self;
}

@end
