//
//  AddressBookHelper.h
//  KnodaIPhoneApp
//
//  Created by nick on 3/19/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Contact : NSObject
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSArray *emailAddresses;
@property (strong, nonatomic) NSArray *phoneNumbers;
@end


@interface AddressBookHelper : NSObject

+ (NSArray *)contactsWithEmailOrPhone;

@end
