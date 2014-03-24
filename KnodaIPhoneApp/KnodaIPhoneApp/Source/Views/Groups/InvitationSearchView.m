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

@property (strong, nonatomic) NSArray *knodaResults;
@property (strong, nonatomic) NSArray *contactsResults;
@property (strong, nonatomic) NSArray *allContacts;
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
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 21)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.frame.size.width - 10, 21.0)];
    label.textColor = [UIColor colorFromHex:@"77BC1F"];
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0];
    label.font = font;
    label.backgroundColor = [UIColor whiteColor];
    [view addSubview:label];
    if (section == 0)
        label.text = @"Your contacts";
    else
        label.text = @"Knoda Users";
    
    if (section == 0 && self.contactsResults.count == 0)
        return nil;
    if (section == 1 && self.knodaResults.count == 0)
        return nil;
    
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return self.contactsResults.count;
    }
    
    if (section == 1)
        return self.knodaResults.count;
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        if (self.knodaResults.count == 0)
            return [NoSearchResultsCell noSearchResultsCellWithTitle:@"No Knoda Users found." forTableView:tableView];
        
        InvitationTableViewCell *cell = [InvitationTableViewCell cellForTableView:tableView onIndexPath:indexPath delegate:nil];
        
        User *user = [self.knodaResults objectAtIndex:indexPath.row];
        
        cell.nameLabel.text = user.name;
        cell.knodaImageView.hidden = NO;
        cell.contactMethodsLabel.hidden = YES;
        return cell;
    }
    
    
    InvitationTableViewCell *cell = [InvitationTableViewCell cellForTableView:tableView onIndexPath:indexPath delegate:nil];
    
    Contact *contact = [self.contactsResults objectAtIndex:indexPath.row];
    
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
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (indexPath.section == 1) {
        if (!self.knodaResults)
            return;
        
        User *user = [self.knodaResults objectAtIndex:indexPath.row];
        [self.delegate invitationSearchViewDidSelectKnodaUser:user];
        [self resetUI];
        return;
    }
    
    Contact *contact = [self.contactsResults objectAtIndex:indexPath.row];
    
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
    self.knodaResults = nil;
    self.contactsResults = nil;
    [self.tableView reloadData];
}

- (void)refreshResults:(NSString *)query {
    if (!query || query.length == 0)
        return;
    
    NSLog(@"SEARCHING FOR %@", self.textfield.text);
    [[WebApi sharedInstance] autoCompleteUsers:query completion:^(NSArray *users, NSError *error) {
        if (!error)
            self.knodaResults = users;
        [self.tableView reloadData];
    }];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name BEGINSWITH[cd] %@", query];
    
    self.contactsResults = [self.allContacts filteredArrayUsingPredicate:predicate];
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
