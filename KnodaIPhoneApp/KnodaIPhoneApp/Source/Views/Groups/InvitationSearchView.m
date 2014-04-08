//
//  InvitationSearchView.m
//  KnodaIPhoneApp
//
//  Created by nick on 3/20/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "InvitationSearchView.h"
#import "SearchSectionHeader.h"
#import "LoadingCell.h"
#import "WebApi.h"  
#import "InvitationTableViewCell.h"
#import "AddressBookHelper.h"
#import "NoSearchResultsCell.h"

@interface InvitationSearchView () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textfield;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *allContacts;
@property (strong, nonatomic) NSMutableArray *results;
@property (strong, nonatomic) Contact *actionSheetContact;
@end

@implementation InvitationSearchView

- (id)initWithDelegate:(id<InvitationSearchViewDelegate>)delegate {
    self = [[[UINib nibWithNibName:@"InvitationSearchView" bundle:[NSBundle mainBundle]] instantiateWithOwner:nil options:nil] firstObject];
    self.delegate = delegate;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    CGRect frame = self.frame;
    frame.size.height = frame.size.height - self.tableView.frame.size.height;
    self.frame = frame;
    self.allContacts = [AddressBookHelper contactsWithEmailOrPhone];
    self.results = [self.allContacts mutableCopy];
    return self;
}
- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (newSuperview) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willShowKeyBoard:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willHideKeyBoard:) name:UIKeyboardWillHideNotification object:nil];
    } else
        [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.results.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id obj = [self.results objectAtIndex:indexPath.row];
    User *user;
    Contact *contact;
    if ([obj isKindOfClass:User.class])
        user = obj;
    else if ([obj isKindOfClass:Contact.class])
        contact = obj;
    
    
    InvitationTableViewCell *cell = [InvitationTableViewCell cellForTableView:tableView onIndexPath:indexPath delegate:nil];
    
    if (user) {
    
        cell.nameLabel.text = user.name;
        cell.knodaImageView.hidden = NO;
        cell.contactMethodsLabel.hidden = YES;
    
    } else if (contact) {
        cell.nameLabel.text = contact.name;
        
        NSMutableString *string = [[NSMutableString alloc] init];
        
        for (NSString *email in contact.emailAddresses) {
            [string appendFormat:@"%@ ", email];
        }
        
        for (NSString *phone in contact.phoneNumbers) {
            [string appendFormat:@"%@ ", phone];
        }
        
        cell.contactMethodsLabel.text = string;
        cell.knodaImageView.hidden = YES;
        cell.contactMethodsLabel.hidden = NO;
    }
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id obj = [self.results objectAtIndex:indexPath.row];
    User *user;
    Contact *contact;
    if ([obj isKindOfClass:User.class])
        user = obj;
    else if ([obj isKindOfClass:Contact.class])
        contact = obj;
    
    
    if (user) {
        [self.delegate invitationSearchViewDidSelectKnodaUser:user];
        [self resetUI];
        return;
    } else if (contact) {
        NSArray *values = [self arrayOfValuesFromContact:contact];
        
        if (values.count == 1) {
            NSString *phoneNumber = [contact.phoneNumbers firstObject];
            if (phoneNumber) {
                [self.delegate invitationSearchViewDidSelectContact:contact withPhoneNumber:phoneNumber];
            }
            NSString *email = [contact.emailAddresses firstObject];
            if (email) {
                [self.delegate invitationSearchViewDidSelectContact:contact withEmail:email];
            }
        } else {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose a contact method" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
            
            for (NSString *value in values) {
                [actionSheet addButtonWithTitle:value];
            }
            actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancel"];
            self.actionSheetContact = contact;
            [actionSheet showInView:self.superview];
        }
        
        
        [self resetUI];
    }
}

- (IBAction)textFieldValueDidChange:(id)sender {
    [self refreshResults:self.textfield.text];
}
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.textfield.clearButtonMode = UITextFieldViewModeAlways;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self resetUI];
    return YES;
}

- (void)resetUI {
    [self.textfield resignFirstResponder];
    self.textfield.text = @"";
    self.results = [self.allContacts mutableCopy];
    [self.tableView reloadData];
}

- (void)addUsersToResults:(NSArray *)users {
    
    NSIndexSet *usersSet = [self.results indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [obj isKindOfClass:User.class];
    }];
    
    [self.results removeObjectsAtIndexes:usersSet];
    
    for (User *user in users) {
        NSInteger indexToInsert = [self.results indexOfObject:user inSortedRange:NSMakeRange(0, self.results.count) options:NSBinarySearchingInsertionIndex usingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSComparisonResult result = [[obj2 name] compare:[obj2 name]];
            if (result == NSOrderedSame) {
                if ([obj2 isKindOfClass:User.class] && [obj1 isKindOfClass:Contact.class])
                    return NSOrderedAscending;
                else if ([obj1 isKindOfClass:User.class] && [obj2 isKindOfClass:Contact.class])
                    return NSOrderedDescending;
                return NSOrderedSame;
            }
            
            return result;
        }];
        [self.results insertObject:user atIndex:indexToInsert];
    }
    
    [self.tableView reloadData];
}

- (void)refreshResults:(NSString *)query {
    if (!query || query.length == 0)
        return;
    
    [self.results removeAllObjects];
    
    NSLog(@"SEARCHING FOR %@", self.textfield.text);
    [[WebApi sharedInstance] autoCompleteUsers:query completion:^(NSArray *users, NSError *error) {
        if (!error)
            [self addUsersToResults:users];
        [self.tableView reloadData];
    }];
    
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(Contact* evaluatedObject, NSDictionary *bindings) {
        
        NSRange prefixRange = [evaluatedObject.name rangeOfString:query
                    options:(NSAnchoredSearch | NSCaseInsensitiveSearch)];
        if (prefixRange.location != NSNotFound)
            return YES;
        
        for (NSString *email in evaluatedObject.emailAddresses) {
            if ([email hasPrefix:query])
                return YES;
        }
        
        for (NSString *phone in evaluatedObject.phoneNumbers) {
            if ([phone hasPrefix:query])
                return YES;
        }
        
        return NO;
    }];
    
    NSArray *contactsResults = [self.allContacts filteredArrayUsingPredicate:predicate];
    [self.results addObjectsFromArray:contactsResults];
    [self.tableView reloadData];
}

- (void)willShowKeyBoard:(NSNotification *)object {
    
    NSDictionary *userInfo = object.userInfo;
    
    CGRect keyBoardFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval animationDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] integerValue];
    
    CGRect frame = self.frame;
    frame.size.height = self.superview.frame.size.height - keyBoardFrame.size.height;
    
    [UIView animateWithDuration:animationDuration animations:^{
        self.frame = frame;
    }];
    
    self.frame = frame;
}

- (void)willHideKeyBoard:(NSNotification *)object {
    CGRect frame = self.frame;
    frame.size.height = frame.size.height - self.tableView.frame.size.height;
    self.frame = frame;
        
    self.frame = frame;
}

- (NSArray *)arrayOfValuesFromContact:(Contact *)contact {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:contact.phoneNumbers.count + contact.emailAddresses.count];
    
    for (NSString *phoneNumber in contact.phoneNumbers) {
        [result addObject:phoneNumber];
    }
    
    for (NSString *email in contact.emailAddresses)
        [result addObject:email];
    
    return result;
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex)
        return;
    
    NSArray *values = [self arrayOfValuesFromContact:self.actionSheetContact];
    
    NSString *selectedValue = [values objectAtIndex:buttonIndex];
    
    if ([selectedValue rangeOfString:@"%@"].location != NSNotFound)
        [self.delegate invitationSearchViewDidSelectContact:self.actionSheetContact withEmail:selectedValue];
    else
        [self.delegate invitationSearchViewDidSelectContact:self.actionSheetContact withPhoneNumber:selectedValue];
    
    [self resetUI];
    self.actionSheetContact = nil;
    
    
}


@end
