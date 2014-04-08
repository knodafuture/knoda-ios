//
//  InvitationsViewController.m
//  KnodaIPhoneApp
//
//  Created by nick on 3/19/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "InvitationsViewController.h"
#import "InvitationTableViewCell.h"
#import "InvitationSearchView.h"
#import "AddressBookHelper.h"
#import "NoContentCell.h"
#import "Invitation.h"
#import "WebApi.h"

@interface InvitationHolder : NSObject
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *phoneNumber;
@property (assign, nonatomic) NSInteger userId;
@end
@implementation InvitationHolder
- (BOOL)isEqual:(id)object {
    InvitationHolder *item2 = (InvitationHolder *)object;
    
    if ([item2.name isEqualToString:self.name]) {
        if (item2.userId)
            return self.userId == item2.userId;
        if (item2.phoneNumber)
            return [self.phoneNumber isEqualToString:item2.phoneNumber];
        if (item2.email)
            return [self.email isEqualToString:item2.email];
    } else
        return NO;
    
    return NO;
}
- (Invitation *)invitation {
    Invitation *inv = [[Invitation alloc] init];
    if (self.userId)
        inv.userId = self.userId;
    if (self.phoneNumber)
        inv.phoneNumber = self.phoneNumber;
    if (self.email)
        inv.email = self.email;
    
    return inv;
}
@end

@interface InvitationsViewController () <UITableViewDataSource, UITableViewDelegate, InvitationSearchViewDelegate, InvitationTableViewCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) InvitationSearchView *searchView;
@property (strong, nonatomic) NSMutableArray *items;
@property (strong, nonatomic) Group *group;
@end

@implementation InvitationsViewController

- (id)initWithGroup:(Group *)group {
    self = [super initWithNibName:@"InvitationsViewController" bundle:[NSBundle mainBundle]];
    self.items = [[NSMutableArray alloc] init];
    self.group = group;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [Flurry logEvent: @"Group_Invitations"];

    [self.tableView reloadData];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.title = @"INVITE";
    self.navigationController.navigationBar.translucent = NO;
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem styledBarButtonItemWithTitle:@"Cancel" target:self action:@selector(cancel) color:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem styledBarButtonItemWithTitle:@"Send" target:self action:@selector(send) color:[UIColor whiteColor]];
    
    self.searchView = [[InvitationSearchView alloc] initWithDelegate:self];
    
    CGRect frame = self.searchView.frame;
    frame.origin.y = 0;
    self.searchView.frame = frame;
    
    [self.view addSubview:self.searchView];
    
    frame = self.tableView.frame;
    frame.origin.y = self.searchView.frame.origin.y + self.searchView.frame.size.height;
    frame.size.height = self.view.frame.size.height - frame.origin.y;
    self.tableView.frame = frame;
}


- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)send {
    NSMutableArray *invitations = [NSMutableArray arrayWithCapacity:self.items.count];
    
    for (InvitationHolder *holder in self.items) {
        Invitation *inv = [holder invitation];
        inv.groupId = self.group.groupId;
        [invitations addObject:inv];
    }
    
    [[WebApi sharedInstance] sendInvites:invitations completion:^(NSArray *invitations, NSError *error) {
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Your invitations are on their way" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            [self cancel];
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.items.count == 0)
        return 1;
    
    return self.items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.items.count == 0)
        return self.tableView.frame.size.height;
    return 55.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.items.count == 0) {
        return [NoContentCell noContentWithMessage:@"Find your friends on Knoda using the search bar above. You can also type a name, phone number, or email address to invite them from your contact list." forTableView:tableView height:self.tableView.frame.size.height];
    }
    
    
    InvitationTableViewCell *cell = [InvitationTableViewCell cellForTableView:tableView onIndexPath:indexPath delegate:self];
    cell.removeButton.hidden = NO;
    
    InvitationHolder *item = [self.items objectAtIndex:indexPath.row];
    
    cell.nameLabel.text = item.name;
    
    if (item.userId) {
        cell.knodaImageView.hidden = NO;
        cell.contactMethodsLabel.hidden = YES;
    } else {
        NSString *contactMethod = item.phoneNumber ? item.phoneNumber : item.email;
        cell.knodaImageView.hidden = YES;
        cell.contactMethodsLabel.hidden = NO;
        cell.contactMethodsLabel.text = contactMethod;
    }
 
    return cell;
}

- (void)invitationSearchViewDidSelectContact:(Contact *)contact withPhoneNumber:(NSString *)phoneNumber {
    InvitationHolder *holder = [[InvitationHolder alloc] init];
    holder.phoneNumber = phoneNumber;
    holder.name = contact.name;
    [self insertItem:holder];
}

- (void)invitationSearchViewDidSelectContact:(Contact *)contact withEmail:(NSString *)email {
    InvitationHolder *holder = [[InvitationHolder alloc] init];
    holder.email = email;
    holder.name = contact.name;
    [self insertItem:holder];
}

- (void)invitationSearchViewDidSelectKnodaUser:(User *)user {
    InvitationHolder *holder = [[InvitationHolder alloc] init];
    holder.userId = user.userId;
    holder.name = user.name;
    [self insertItem:holder];
}

- (void)insertItem:(InvitationHolder *)item {
    
    if ([self.items containsObject:item])
        return;
    
    NSInteger index = [self.items indexOfObject:item inSortedRange:(NSRange){0, self.items.count} options:NSBinarySearchingInsertionIndex
        usingComparator:^NSComparisonResult(InvitationHolder* obj1, InvitationHolder* obj2) {
            return [obj1.name compare:obj2.name];
        
    }];
    
    [self.items insertObject:item atIndex:index];
    [self.tableView reloadData];
    
}

- (void)InvitationTableViewCell:(InvitationTableViewCell *)cell didRemoveOnIndexPath:(NSIndexPath *)indexPath {
    
    [self.items removeObjectAtIndex:indexPath.row];
    [self.tableView reloadData];
}

@end
