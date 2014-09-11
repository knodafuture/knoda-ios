//
//  AddressBookHelper.m
//  KnodaIPhoneApp
//
//  Created by nick on 3/19/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "AddressBookHelper.h"
#import <AddressBook/AddressBook.h>

@implementation Contact
- (id)init {
    self = [super init];
    self.phoneNumbers = @[];
    self.emailAddresses = @[];
    return self;
}
@end

@interface AddressBookHelper () {
}

@end
@implementation AddressBookHelper

+ (NSArray *)contactsWithEmailOrPhone {
    CFErrorRef *error = nil;
    ABAddressBookRef addressBook;
    
    addressBook = ABAddressBookCreateWithOptions(NULL, error);
    __block BOOL accessGranted;
    if (ABAddressBookRequestAccessWithCompletion != NULL) {
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        
    }
    else {
        accessGranted = YES;
    }
    
    if (accessGranted) {
//        NSMutableArray* items = [NSMutableArray array];
//
//        CFArrayRef allSources = ABAddressBookCopyArrayOfAllSources(addressBook);
//        for (CFIndex i = 0; i < CFArrayGetCount(allSources); i++) {
//            ABRecordRef source = (ABRecordRef)CFArrayGetValueAtIndex(allSources, i);
//            CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, source, kABPersonSortByFirstName);
//            NSArray *sortedPeople = CFBridgingRelease(allPeople);
        //            for (int i = 0; i < sortedPeople.count; i++) {
        //                ABRecordRef person = (__bridge ABRecordRef)([sortedPeople objectAtIndex:i]);
        //                Contact *contact = [self processRecord:person];
        //
        //                if (contact)
        //                    [items addObject:contact];
        //            }
//        }
//        
//        CFRelease(allSources);
//        CFRelease(addressBook);
//        return items;
        
        NSMutableArray *items = [NSMutableArray array];
        NSMutableSet *unifiedRecordsSet = [NSMutableSet set];
        CFArrayRef records = ABAddressBookCopyArrayOfAllPeople(addressBook);
        for (CFIndex i = 0; i < CFArrayGetCount(records); i++)
        {
            NSMutableSet *contactSet = [NSMutableSet set];
            
            ABRecordRef record = CFArrayGetValueAtIndex(records, i);
            [contactSet addObject:(__bridge id)record];
            
            NSArray *linkedRecordsArray = (__bridge NSArray *)ABPersonCopyArrayOfAllLinkedPeople(record);
            [contactSet addObjectsFromArray:linkedRecordsArray];
            [unifiedRecordsSet addObject:contactSet];
            // Your own custom "unified record" class (or just an NSSet!)

            CFRelease(record);

        }
        
        for (NSSet *contactSet in unifiedRecordsSet) {
            Contact *contact = [self processSet:contactSet];
            if (contact)
                [items addObject:contact];
        }
        
        CFRelease(records);
        CFRelease(addressBook);
        
        return [items sortedArrayUsingComparator:^NSComparisonResult(Contact *obj1, Contact  *obj2) {
            return [obj1.name compare:obj2.name];
        }];;
        
        
    } else {
        return nil;
    }
}

+ (Contact *)processSet:(NSSet *)set {
    Contact *contact = [[Contact alloc] init];
    id obj = [set anyObject];
    //for (id obj in set) {
        ABRecordRef person = (__bridge ABRecordRef)obj;
        contact = [self processRecord:person withExistingContact:contact];
    //}
    return contact;
}

+ (Contact *)processRecord:(ABRecordRef)person withExistingContact:(Contact *)contact {
    NSString *firstName;
    NSString *lastName;
    
    CFStringRef firstNameRef = ABRecordCopyValue(person, kABPersonFirstNameProperty);
    CFStringRef lastNameRef = ABRecordCopyValue(person, kABPersonLastNameProperty);
    
    if (firstNameRef != NULL)
        firstName = CFBridgingRelease(firstNameRef);
    if (lastNameRef != NULL)
        lastName = CFBridgingRelease(lastNameRef);
    
    if (firstName) {
        if (lastName)
            contact.name = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        else
            contact.name = firstName;
    } else if (lastName)
        contact.name = lastName;
    
    if (!contact.name)
        return nil;
    
    
    NSMutableArray *phoneNumbers = contact.phoneNumbers.mutableCopy;
    
    ABMultiValueRef multiPhones = ABRecordCopyValue(person, kABPersonPhoneProperty);
    for(CFIndex i=0;i<ABMultiValueGetCount(multiPhones);i++) {
        
        NSString *phoneNumber = CFBridgingRelease(ABMultiValueCopyValueAtIndex(multiPhones, i));
        if (![phoneNumbers containsObject:phoneNumber])
            [phoneNumbers addObject:phoneNumber];
    }
    
    contact.phoneNumbers = phoneNumbers;
    if (multiPhones != NULL)
        CFRelease(multiPhones);
    
    NSMutableArray *contactEmails = contact.emailAddresses.mutableCopy;
    ABMultiValueRef multiEmails = ABRecordCopyValue(person, kABPersonEmailProperty);
    
    for (CFIndex i=0; i<ABMultiValueGetCount(multiEmails); i++) {
        NSString *contactEmail = CFBridgingRelease(ABMultiValueCopyValueAtIndex(multiEmails, i));
        if (![contactEmails containsObject:contactEmail])
            [contactEmails addObject:contactEmail];
    }
    contact.emailAddresses = contactEmails;
    if (multiEmails != NULL)
        CFRelease(multiEmails);
    
    return contact;
}

+ (Contact *)processRecord:(ABRecordRef)person {
    Contact *contact = [[Contact alloc] init];

    return [self processRecord:person withExistingContact:contact];
}

@end
