//
//  TallyUser.h
//  KnodaIPhoneApp
//
//  Created by nick on 1/3/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "WebObject.h"

@interface TallyUser : WebObject

@property (assign, nonatomic) BOOL agree;
@property (assign, nonatomic) NSInteger userId;
@property (strong, nonatomic) NSString *username;
@property (assign, nonatomic) BOOL verifiedAccount;
@end
