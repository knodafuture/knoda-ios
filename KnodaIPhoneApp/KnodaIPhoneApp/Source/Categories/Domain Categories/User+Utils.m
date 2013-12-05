//
//  NewUser+Utils.m
//  KnodaIPhoneApp
//
//  Created by nick on 12/5/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "User+Utils.h"

@implementation User (Utils)

- (BOOL)hasAvatar {
    return self.largeImageUrl.length && self.smallImageUrl.length && self.thumbImageUrl.length;
}

@end
