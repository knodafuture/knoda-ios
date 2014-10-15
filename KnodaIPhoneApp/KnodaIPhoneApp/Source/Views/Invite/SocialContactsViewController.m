//
//  SocialContactsViewController.m
//  KnodaIPhoneApp
//
//  Created by nick on 8/25/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "SocialContactsViewController.h"
#import "AddressBookHelper.h"
#import "SocialContactsTableViewCell.h"
#import "EmptyDatasource.h"
#import "LoadingCell.h" 
#import "WebApi.h"  
#import "SocialFollowTableViewCell.h"

@interface SocialContactsViewController () <UIActionSheetDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, SocialContactsTableViewCellDelegate, SocialFollowTableViewCellDelegate, ImageLoaderDelegate>
@property (strong, nonatomic) NSArray *allContacts;
@property (strong, nonatomic) NSMutableArray *searchedContacts;
@property (strong, nonatomic) NSArray *knodaContacts;
@property (strong, nonatomic) NSMutableArray *searchedKnodaContacts;
@property (strong, nonatomic) EmptyDatasource *emptyDataSource;
@property (strong, nonatomic) ImageLoader *imageLoader;
@property (assign, nonatomic) BOOL selectAll;
@property (weak, nonatomic) IBOutlet UIButton *selectAllButton;
@property (assign, nonatomic) BOOL hasKnodaResults;
@property (strong, nonatomic) Contact *actionSheetContact;
@end

@implementation SocialContactsViewController

- (id)initWithDelegate:(id<SocialFollowTableViewControllerDelegate>)delegate {
    self = [super initWithNibName:@"SocialContactsViewController" bundle:[NSBundle mainBundle]];
    self.delegate = delegate;
    self.selectAll = NO;
    self.hasKnodaResults = YES;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIColor *color = [UIColor colorFromHex:@"77BC1F"];
    self.searchField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Search Contacts" attributes:@{NSForegroundColorAttributeName: color}];
    self.tableView.separatorColor = [UIColor colorFromHex:@"efefef"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    self.imageLoader = [[ImageLoader alloc] initForTable:self.tableView delegate:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.allContacts = [AddressBookHelper contactsWithEmailOrPhone];
    self.searchedContacts = [self.allContacts mutableCopy];
    [self.tableView reloadData];
    CGRect frame = self.tableView.frame;
    frame.size.width = self.view.frame.size.width;
    frame.size.height = self.view.frame.size.height - self.searchField.frame.size.height;
    self.tableView.frame = frame;
    if (!self.allContacts)
        [self showNoContent];
    else {
        [[WebApi sharedInstance] matchContacts:[ContactMatch arrayFromContacts:self.allContacts] completion:^(NSArray *matches, NSError *error) {
            
            NSMutableArray *filtered = [NSMutableArray arrayWithCapacity:self.allContacts.count];
            
            for (Contact *contact in self.allContacts) {
                BOOL found = NO;
                for (ContactMatch *match in matches) {
                    if ([contact.name isEqualToString:match.contactId])
                        found = YES;
                }
                if (!found)
                    [filtered addObject:contact];
            }
            self.allContacts = [NSArray arrayWithArray:filtered];
            self.searchedContacts = self.allContacts.mutableCopy;
            self.knodaContacts = matches;
            self.searchedKnodaContacts = matches.mutableCopy;
            
            self.hasKnodaResults = self.knodaContacts.count > 0;
            [self sortAndReload];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                if (!self.selectAll)
                    [self selectAll:nil];
            });
        }];
    }
}

- (void)showNoContent {
    self.emptyDataSource = [[EmptyDatasource alloc] init];
    self.emptyDataSource.cell = [[[UINib nibWithNibName:@"NoContactsCell" bundle:[NSBundle mainBundle]] instantiateWithOwner:nil options:nil] lastObject];
    self.tableView.delegate = self.emptyDataSource;
    self.tableView.dataSource = self.emptyDataSource;
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.hasKnodaResults)
        return 2;
    else
        return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 36.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (self.hasKnodaResults) {
        if (section == 0) {
            UIView *view =  [[[UINib nibWithNibName:@"KnodaContactsHeaderView" bundle:[NSBundle mainBundle]] instantiateWithOwner:self options:nil] lastObject];
            if (!self.selectAll) {
                [self.selectAllButton setImage:[UIImage imageNamed:@"InviteCheckbox"] forState:UIControlStateNormal];
            } else {
                [self.selectAllButton setImage:[UIImage imageNamed:@"InviteCheckboxActive"] forState:UIControlStateNormal];
            }
            return view;
        }
        else
            return [[[UINib nibWithNibName:@"SocialContactsHeaderView" bundle:[NSBundle mainBundle]] instantiateWithOwner:nil options:nil] lastObject];
    } else
        return [[[UINib nibWithNibName:@"SocialContactsHeaderView" bundle:[NSBundle mainBundle]] instantiateWithOwner:nil options:nil] lastObject];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.hasKnodaResults) {
    
        if (section == 0) {
            if (self.searchedKnodaContacts.count == 0)
                return 1;
            return self.searchedKnodaContacts.count;
        } else {
        
            if (self.searchedContacts.count == 0)
                return 1;
            
            return self.searchedContacts.count;
        }
    } else {
        if (self.searchedContacts.count == 0)
            return 1;
        
        return self.searchedContacts.count;
    }
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (self.hasKnodaResults) {
//        
//        if (section == 0) {
//            if (self.searchedKnodaContacts.count == 0)
//                return 1;
//            return self.searchedKnodaContacts.count;
//        } else {
//            
//            if (self.searchedContacts.count == 0)
//                return 1;
//            
//            return self.searchedContacts.count;
//        }
//    } else {
//        if (self.searchedContacts.count == 0)
//            return 1;
//        
//        return self.searchedContacts.count;
//    }
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.hasKnodaResults) {
        if (indexPath.section == 0) {
            if (self.searchedKnodaContacts.count == 0 && self.knodaContacts)
                return 54;
            else if (self.searchedKnodaContacts.count == 0)
                return loadingCellHeight;
            else
                return 44.0;
        } else {
            if (self.searchedContacts.count == 0 && self.allContacts.count != 0)
                return 165;
            else if (self.searchedContacts.count == 0)
                return loadingCellHeight;
            return 44.0;
        }
    } else {
        if (self.searchedContacts.count == 0 && self.allContacts.count != 0)
            return 165;
        else if (self.searchedContacts.count == 0)
            return loadingCellHeight;
        return 44.0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell respondsToSelector:@selector(toggleSelected:)]) {
        [cell toggleSelected:nil];
    } else if ([cell respondsToSelector:@selector(toggleChecked:)]) {
        [cell toggleChecked:nil];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.hasKnodaResults) {
        if (indexPath.section == 0) {
            if (self.searchedKnodaContacts.count == 0) {
                if (self.knodaContacts)
                    return [[[UINib nibWithNibName:@"NoContactResultsCell" bundle:[NSBundle mainBundle]] instantiateWithOwner:nil options:nil] lastObject];
                else
                    return [LoadingCell loadingCellForTableView:tableView];
            }
            
            SocialFollowTableViewCell *cell = [SocialFollowTableViewCell cellForTableView:tableView delegate:self indexPath:indexPath];
            
            ContactMatch *match = [self.searchedKnodaContacts objectAtIndex:indexPath.row];
            
            cell.contactIdLabel.text = match.contactId;
            cell.usernameLabel.text = match.info.username;
            cell.avatarImageView.image = [_imageLoader lazyLoadImage:match.info.avatar.small onIndexPath:indexPath];
            cell.checked = match.selected;
            return cell;
            
        } else {
            
            if (self.searchedContacts.count == 0) {
                if (self.allContacts.count != 0)
                    return [[[UINib nibWithNibName:@"NoContactResultsCell" bundle:[NSBundle mainBundle]] instantiateWithOwner:nil options:nil] lastObject];
                else
                    return [LoadingCell loadingCellForTableView:tableView];
            }
            
            SocialContactsTableViewCell *cell = [SocialContactsTableViewCell cellForTableView:tableView delegate:self indexPath:indexPath];
            
            Contact *contact = self.searchedContacts[indexPath.row];
            
            cell.nameLabel.text = contact.name;
            
            NSMutableString *contactMethods = [[NSMutableString alloc] init];
            BOOL foundFirst = NO;
            for (int i = 0; i < contact.phoneNumbers.count; i++) {
                if (foundFirst)
                    [contactMethods appendFormat:@", %@", [self formatPhoneNumber:contact.phoneNumbers[i] deleteLastChar:NO]];
                else
                    [contactMethods appendFormat:@"%@", [self formatPhoneNumber:contact.phoneNumbers[i] deleteLastChar:NO]];
                foundFirst = YES;
            }
            
            for (int i = 0; i < contact.emailAddresses.count; i++) {
                if (foundFirst)
                    [contactMethods appendFormat:@", %@", contact.emailAddresses[i]];
                else
                    [contactMethods appendFormat:@"%@", contact.emailAddresses[i]];
                foundFirst = YES;
            }
            
            if (contact.selectedEmailAddress)
                cell.contactMethodsLabel.text = contact.selectedEmailAddress;
            else if (contact.selectedPhoneNumber)
                cell.contactMethodsLabel.text = [self formatPhoneNumber:contact.selectedPhoneNumber deleteLastChar:NO];
            else
                cell.contactMethodsLabel.text = contactMethods;
            
            cell.contactSelected = contact.selected;
            
            return cell;
        }
    } else {
        if (self.searchedContacts.count == 0) {
            if (self.allContacts.count != 0)
                return [[[UINib nibWithNibName:@"NoContactResultsCell" bundle:[NSBundle mainBundle]] instantiateWithOwner:nil options:nil] lastObject];
            else
                return [LoadingCell loadingCellForTableView:tableView];
        }
        
        SocialContactsTableViewCell *cell = [SocialContactsTableViewCell cellForTableView:tableView delegate:self indexPath:indexPath];
        
        Contact *contact = self.searchedContacts[indexPath.row];
        
        cell.nameLabel.text = contact.name;
        
        NSMutableString *contactMethods = [[NSMutableString alloc] init];
        BOOL foundFirst = NO;
        for (int i = 0; i < contact.phoneNumbers.count; i++) {
            if (foundFirst)
                [contactMethods appendFormat:@", %@", [self formatPhoneNumber:contact.phoneNumbers[i] deleteLastChar:NO]];
            else
                [contactMethods appendFormat:@"%@", [self formatPhoneNumber:contact.phoneNumbers[i] deleteLastChar:NO]];
            foundFirst = YES;
        }
        
        for (int i = 0; i < contact.emailAddresses.count; i++) {
            if (foundFirst)
                [contactMethods appendFormat:@", %@", contact.emailAddresses[i]];
            else
                [contactMethods appendFormat:@"%@", contact.emailAddresses[i]];
            foundFirst = YES;
        }
        
        if (contact.selectedEmailAddress)
            cell.contactMethodsLabel.text = contact.selectedEmailAddress;
        else if (contact.selectedPhoneNumber)
            cell.contactMethodsLabel.text = [self formatPhoneNumber:contact.selectedPhoneNumber deleteLastChar:NO];
        else
            cell.contactMethodsLabel.text = contactMethods;
        
        cell.contactSelected = contact.selected;
        
        return cell;
    }
    

}

- (void)contactSelectedInCell:(SocialContactsTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {

    Contact *contact = self.searchedContacts[indexPath.row];
    contact.selected = YES;
    NSString *contactId = contact.name;

    
    NSArray *values = [self arrayOfValuesFromContact:contact];
    
    if (values.count == 1) {
        NSString *phoneNumber = [contact.phoneNumbers firstObject];
        if (phoneNumber) {
            contact.selectedPhoneNumber = phoneNumber;
            contact.selectedEmailAddress = nil;
        }
        NSString *email = [contact.emailAddresses firstObject];
        if (email) {
            contact.selectedEmailAddress = email;
            contact.selectedPhoneNumber = nil;
        }
    } else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose a contact method" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        
        for (NSString *value in values) {
            [actionSheet addButtonWithTitle:value];
        }
        actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancel"];
        self.actionSheetContact = contact;
        [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    }
    for (Contact *c in self.allContacts) {
        if ([c.name isEqualToString:contactId] && c.phoneNumbers == contact.phoneNumbers && c.emailAddresses == contact.emailAddresses) {
            c.selected = YES;
            c.selectedEmailAddress = contact.selectedEmailAddress;
            c.selectedPhoneNumber = contact.selectedPhoneNumber;
        }
    }
    [self sortAndReload];
    [self notifyParent];
}

- (void)contactUnselectedInCell:(SocialContactsTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Contact *contact = self.searchedContacts[indexPath.row];
    contact.selected = NO;
    NSString *contactId = contact.name;
    
    for (Contact *c in self.allContacts) {
        if ([c.name isEqualToString:contactId] && c.phoneNumbers == contact.phoneNumbers && c.emailAddresses == contact.emailAddresses) {
            c.selected = NO;
            c.selectedEmailAddress = nil;
            c.selectedPhoneNumber = nil;
        }
        
    }
    
    [self sortAndReload];
    [self notifyParent];
}

- (void)notifyParent {
    [self.delegate selectionUpdatedInViewController:(SocialFollowTableViewController *)self];
}

- (NSArray *)invitations {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.allContacts.count];
    
    for (Contact *contact in self.allContacts) {
        if (contact.selected)
            [array addObject:contact];
    }
    
    return [NSArray arrayWithArray:array];
}

- (NSArray *)selectedMatches {
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:self.knodaContacts.count];
    
    for (ContactMatch *match in self.knodaContacts) {
        if (match.selected)
            [array addObject:match];
    }
    
    return [NSArray arrayWithArray:array];
}

- (IBAction)textFieldValueDidChange:(id)sender {
    [self refreshResults:self.searchField.text];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.clearButton.hidden = NO;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@"\n"]) {
        [self.view endEditing:YES];
        return NO;
    }
    return YES;
}

- (void)refreshResults:(NSString *)query {
    if (!query || query.length == 0)
        return;
    
    [self.searchedContacts removeAllObjects];
    [self.searchedKnodaContacts removeAllObjects];
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(Contact* evaluatedObject, NSDictionary *bindings) {
        
        NSRange prefixRange = [evaluatedObject.name rangeOfString:query
                                                          options:(NSCaseInsensitiveSearch)];
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
    
    NSPredicate *knodaPrediction = [NSPredicate predicateWithBlock:^BOOL(ContactMatch* evaluatedObject, NSDictionary *bindings) {
        
        NSRange prefixRange = [evaluatedObject.info.username rangeOfString:query
                                                          options:(NSCaseInsensitiveSearch)];
        if (prefixRange.location != NSNotFound)
            return YES;
        
        NSRange contactIdRange = [evaluatedObject.contactId rangeOfString:query options:(NSCaseInsensitiveSearch)];
        if (contactIdRange.location != NSNotFound)
            return YES;
        
        return NO;
    }];
    
    NSArray *contactsResults = [self.allContacts filteredArrayUsingPredicate:predicate];
    NSArray *knodaContactResults = [self.knodaContacts filteredArrayUsingPredicate:knodaPrediction];
    [self.searchedContacts addObjectsFromArray:contactsResults];
    [self.searchedKnodaContacts addObjectsFromArray:knodaContactResults];
    [self sortAndReload];
}

- (IBAction)clearSearch:(id)sender {
    [self.view endEditing:YES];
    self.clearButton.hidden = YES;
    self.searchField.text = @"";
    self.searchedContacts = [self.allContacts mutableCopy];
    self.searchedKnodaContacts = [self.knodaContacts mutableCopy];
    [self sortAndReload];
    
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)selectAll:(id)sender {
    if (self.selectAll) {
        [self.selectAllButton setImage:[UIImage imageNamed:@"InviteCheckbox"] forState:UIControlStateNormal];
        self.selectAll = NO;
    } else {
        [self.selectAllButton setImage:[UIImage imageNamed:@"InviteCheckboxActive"] forState:UIControlStateNormal];
        self.selectAll = YES;
    }
    
    for (SocialFollowTableViewCell *cell in self.tableView.visibleCells) {
        if ([cell respondsToSelector:@selector(setChecked:)])
            [cell setChecked:self.selectAll];
    }
    
    for (ContactMatch *match in self.searchedKnodaContacts) {
        [match setSelected:self.selectAll];
        NSString *contactId = match.contactId;
        
        for (ContactMatch *match in self.knodaContacts) {
            if ([contactId isEqualToString:match.contactId])
                match.selected = self.selectAll;
        }
    }
    
    [self notifyParent];
}

- (void)matchSelectedInSocialFollowTableViewCell:(SocialFollowTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"matched selected");
    ContactMatch *match = [self.searchedKnodaContacts objectAtIndex:indexPath.row];
    match.selected = YES;
    NSString *contactId = match.contactId;
    
    for (ContactMatch *match in self.knodaContacts) {
        if ([contactId isEqualToString:match.contactId])
            match.selected = YES;
    }
    
    [self notifyParent];
}

- (void)matchUnselectedInSocialFollowTableViewCell:(SocialFollowTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"match unselected");
    
    ContactMatch *match = [self.searchedKnodaContacts objectAtIndex:indexPath.row];
    match.selected = NO;
    NSString *contactId = match.contactId;
    
    for (ContactMatch *match in self.knodaContacts) {
        if ([contactId isEqualToString:match.contactId])
            match.selected = NO;
    }
    if (self.selectAll) {
    [self.selectAllButton setImage:[UIImage imageNamed:@"InviteCheckbox"] forState:UIControlStateNormal];
        self.selectAll = NO;
    }
    [self notifyParent];
}

- (UIImage *)imageLoader:(ImageLoader *)loader willCacheImage:(UIImage *)image forIndexPath:(NSIndexPath *)indexPath {
    return image;
}

- (void)imageLoader:(ImageLoader *)loader finishedLoadingImage:(UIImage *)image forIndexPath:(NSIndexPath *)indexPath {
    SocialFollowTableViewCell *cell = (SocialFollowTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if (![cell isKindOfClass:SocialFollowTableViewCell.class])
        return;
    cell.avatarImageView.image = image;
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
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        self.actionSheetContact.selected = NO;
        [self sortAndReload];
        return;
    }
    
    NSArray *values = [self arrayOfValuesFromContact:self.actionSheetContact];
    
    Contact *contact = nil;
    
    for (Contact *c in self.allContacts) {
        if ([c.name isEqualToString:self.actionSheetContact.name])
            contact = c;
    }
    
    contact.selectedPhoneNumber = nil;
    contact.selectedEmailAddress = nil;
    NSString *selectedValue = [values objectAtIndex:buttonIndex];
    
    if ([selectedValue rangeOfString:@"@"].location != NSNotFound)
        contact.selectedEmailAddress = selectedValue;
    else
        contact.selectedPhoneNumber = selectedValue;
    
    contact.selected = YES;
    
    self.actionSheetContact = nil;
    for (Contact *c in self.searchedContacts) {
    if ([c.name isEqualToString:contact.name] && c.phoneNumbers == contact.phoneNumbers && c.emailAddresses == contact.emailAddresses) {
            c.selected = YES;
            c.selectedEmailAddress = contact.selectedEmailAddress;
            c.selectedPhoneNumber = contact.selectedPhoneNumber;
        }
    }
    
    [self sortAndReload];
    
    
}

-(NSString*) formatPhoneNumber:(NSString*) simpleNumber deleteLastChar:(BOOL)deleteLastChar {
    if(simpleNumber.length==0) return @"";
    // use regex to remove non-digits(including spaces) so we are left with just the numbers
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[\\s-\\(\\)]" options:NSRegularExpressionCaseInsensitive error:&error];
    simpleNumber = [regex stringByReplacingMatchesInString:simpleNumber options:0 range:NSMakeRange(0, [simpleNumber length]) withTemplate:@""];
    
    if ([simpleNumber rangeOfString:@"+"].location != NSNotFound) {
        simpleNumber = [simpleNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    }
    
    // check if the number is to long
    if(simpleNumber.length>11) {
        // remove last extra chars.
        simpleNumber = [simpleNumber substringToIndex:11];
    }
    
    if(deleteLastChar) {
        // should we delete the last digit?
        simpleNumber = [simpleNumber substringToIndex:[simpleNumber length] - 1];
    }
    
    // 123 456 7890
    // format the number.. if it's less then 7 digits.. then use this regex.
    if(simpleNumber.length<7)
        simpleNumber = [simpleNumber stringByReplacingOccurrencesOfString:@"(\\d{3})(\\d+)"
                                                               withString:@"($1) $2"
                                                                  options:NSRegularExpressionSearch
                                                                    range:NSMakeRange(0, [simpleNumber length])];
    
    else if (simpleNumber.length >= 7 && simpleNumber.length < 11)  // else do this one..
        simpleNumber = [simpleNumber stringByReplacingOccurrencesOfString:@"(\\d{3})(\\d{3})(\\d+)"
                                                               withString:@"($1) $2-$3"
                                                                  options:NSRegularExpressionSearch
                                                                    range:NSMakeRange(0, [simpleNumber length])];
    else
        simpleNumber = [simpleNumber stringByReplacingOccurrencesOfString:@"(\\d{1})(\\d{3})(\\d{3})(\\d+)"
                                                               withString:@"+$1 ($2) $3-$4"
                                                                  options:NSRegularExpressionSearch
                                                                    range:NSMakeRange(0, [simpleNumber length])];
    return simpleNumber;
}

- (void)sortAndReload {
    self.searchedContacts = [self.searchedContacts sortedArrayUsingComparator:^NSComparisonResult(Contact *obj1, Contact *obj2) {
        if (obj1.selected && !obj2.selected)
            return NSOrderedAscending;
        else if (obj2.selected && !obj1.selected)
            return NSOrderedDescending;
        
        else
            return [obj1.name compare:obj2.name];
    }].mutableCopy;
    
    self.allContacts = [self.allContacts sortedArrayUsingComparator:^NSComparisonResult(Contact *obj1, Contact *obj2) {
        if (obj1.selected && !obj2.selected)
            return NSOrderedAscending;
        else if (obj2.selected && !obj1.selected)
            return NSOrderedDescending;
        
        else
            return [obj1.name compare:obj2.name];
    }].mutableCopy;
    
    [self.tableView reloadData];
}

@end
