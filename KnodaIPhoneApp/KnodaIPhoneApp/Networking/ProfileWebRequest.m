//
//  ProfileWebRequest.m
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 19.08.13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "ProfileWebRequest.h"

#import "User.h"

@interface ProfileWebRequest() {
    BOOL _isPatch;
}

@end

@implementation ProfileWebRequest

- (id)initWithAvatar:(UIImage *)avatarImage {
    NSDictionary *params = @{kImages : @{@"user[avatar]" : UIImagePNGRepresentation(avatarImage)}};
    if(self = [super initWithParameters:params]) {
        _isPatch = YES;
    }
    return self;
}

- (NSString *)httpMethod {
    return _isPatch ? @"PATCH" : @"GET";
}

- (NSString *)methodName {
    return @"profile.json";
}

- (BOOL)requiresAuthToken {
    return YES;
}

- (BOOL)isMultipartData {
    return _isPatch;
}

- (void)fillResultObject:(id)parsedResult {
    DLog(@"%@", parsedResult);
    _user = [[User alloc] initWithDictionary:parsedResult];
}

@end
