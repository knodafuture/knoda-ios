//
//  ContactMatch.m
//  KnodaIPhoneApp
//
//  Created by nick on 8/28/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "ContactMatch.h"
#import "AddressBookHelper.h"

@implementation ContactMatch
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"contactId": @"contact_id",
             @"phones": @"phones",
             @"emails": @"emails",
             @"info" : @"knoda_info"
             };
}
+ (NSValueTransformer *)infoJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:ContactMatchInfo.class];
}

+ (NSArray *)arrayFromContacts:(NSArray *)array {
    NSMutableArray *mutable = [NSMutableArray arrayWithCapacity:array.count];
    
    for (Contact *contact in array) {
        ContactMatch *match = [[ContactMatch alloc] init];
        match.contactId = contact.name;
        match.phones = contact.phoneNumbers;
        match.emails = contact.emailAddresses;
        [mutable addObject:match];
    }
    
    return [NSArray arrayWithArray:mutable];
    
}

@end

@implementation ContactMatchInfo

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"userId": @"user_id",
             @"username": @"username",
             @"avatar" : @"avatar_image"};
}

+ (NSValueTransformer *)avatarJSONTransformer {
    return [super remoteImageTransformer];
}

@end