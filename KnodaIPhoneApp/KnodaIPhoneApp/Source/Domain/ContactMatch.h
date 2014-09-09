//
//  ContactMatch.h
//  KnodaIPhoneApp
//
//  Created by nick on 8/28/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "WebObject.h"
#import "RemoteImage.h"

@interface ContactMatchInfo : WebObject
@property (strong, nonatomic) NSNumber *userId;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) RemoteImage *avatar;
@property (assign, nonatomic) BOOL following;
@end

@interface ContactMatch : WebObject
@property (strong, nonatomic) NSString *contactId;
@property (strong, nonatomic) NSArray *phones;
@property (strong, nonatomic) NSArray *emails;
@property (strong, nonatomic) ContactMatchInfo *info;
@property (assign, nonatomic) BOOL selected;


+ (NSArray *)arrayFromContacts:(NSArray *)array;
@end


