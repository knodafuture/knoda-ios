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

@interface SocialContactsViewController () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, SocialContactsTableViewCellDelegate, SocialFollowTableViewCellDelegate, ImageLoaderDelegate>
@property (strong, nonatomic) NSArray *allContacts;
@property (strong, nonatomic) NSMutableArray *searchedContacts;
@property (strong, nonatomic) NSArray *knodaContacts;
@property (strong, nonatomic) NSMutableArray *searchedKnodaContacts;
@property (strong, nonatomic) EmptyDatasource *emptyDataSource;
@property (strong, nonatomic) ImageLoader *imageLoader;
@property (assign, nonatomic) BOOL selectAll;
@property (weak, nonatomic) IBOutlet UIButton *selectAllButton;
@end

@implementation SocialContactsViewController

- (id)initWithDelegate:(id<SocialFollowTableViewControllerDelegate>)delegate {
    self = [super initWithNibName:@"SocialContactsViewController" bundle:[NSBundle mainBundle]];
    self.delegate = delegate;
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
    if (!self.allContacts)
        [self showNoContent];
    else {
        [[WebApi sharedInstance] matchContacts:[ContactMatch arrayFromContacts:self.allContacts] completion:^(NSArray *matches, NSError *error) {
            self.knodaContacts = matches;
            self.searchedKnodaContacts = matches.mutableCopy;
            [self.tableView reloadData];
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
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 36.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0)
        return [[[UINib nibWithNibName:@"KnodaContactsHeaderView" bundle:[NSBundle mainBundle]] instantiateWithOwner:self options:nil] lastObject];
    else
        return [[[UINib nibWithNibName:@"SocialContactsHeaderView" bundle:[NSBundle mainBundle]] instantiateWithOwner:nil options:nil] lastObject];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        if (self.searchedKnodaContacts.count == 0)
            return 1;
        return self.searchedKnodaContacts.count;
    } else {
    
        if (self.searchedContacts.count == 0)
            return 1;
        
        return self.searchedContacts.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        if (self.searchedKnodaContacts.count == 0 && self.knodaContacts)
            return 165;
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
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
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
                [contactMethods appendFormat:@", %@", contact.phoneNumbers[i]];
            else
                [contactMethods appendFormat:@"%@", contact.phoneNumbers[i]];
            foundFirst = YES;
        }
        
        for (int i = 0; i < contact.emailAddresses.count; i++) {
            if (foundFirst)
                [contactMethods appendFormat:@", %@", contact.emailAddresses[i]];
            else
                [contactMethods appendFormat:@"%@", contact.emailAddresses[i]];
            foundFirst = YES;
        }
        
        cell.contactMethodsLabel.text = contactMethods;
        
        cell.contactSelected = contact.selected;
        
        return cell;
    }
}

- (void)contactSelectedInCell:(SocialContactsTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Contact *contact = self.searchedContacts[indexPath.row];
    contact.selected = YES;
    NSString *contactId = contact.name;
    for (Contact *c in self.allContacts) {
        if ([c.name isEqualToString:contactId])
            c.selected = YES;
    }
    [self notifyParent];
}

- (void)contactUnselectedInCell:(SocialContactsTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Contact *contact = self.searchedContacts[indexPath.row];
    contact.selected = NO;
    NSString *contactId = contact.name;
    
    for (Contact *c in self.allContacts) {
        if ([c.name isEqualToString:contactId])
            c.selected = NO;
    }
    
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
    [self.tableView reloadData];
}

- (IBAction)clearSearch:(id)sender {
    [self.view endEditing:YES];
    self.searchField.text = @"";
    self.searchedContacts = [self.allContacts mutableCopy];
    self.searchedKnodaContacts = [self.knodaContacts mutableCopy];
    [self.tableView reloadData];
    
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
    if (self.selectAll)
        [self selectAll:nil];
    
    ContactMatch *match = [self.searchedKnodaContacts objectAtIndex:indexPath.row];
    match.selected = NO;
    NSString *contactId = match.contactId;
    
    for (ContactMatch *match in self.knodaContacts) {
        if ([contactId isEqualToString:match.contactId])
            match.selected = NO;
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


@end
