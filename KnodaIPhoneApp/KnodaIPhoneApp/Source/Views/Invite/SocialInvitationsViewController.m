//
//  InvitationsViewController.m
//  KnodaIPhoneApp
//
//  Created by nick on 8/23/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "AddressBookHelper.h"
#import "SocialInvitationsViewController.h"
#import "SocialFollowTableViewController.h"
#import "SocialContactsViewController.h"
#import "Invitation.h"
#import "WebApi.h"
#import "Follower.h"
#import "LoadingView.h"
#import "UserManager.h"

@interface SocialInvitationsViewController () <SocialFollowTableViewControllerDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (assign, nonatomic) NSInteger followCount;
@property (assign, nonatomic) NSInteger inviteCount;
@property (weak, nonatomic) id<UIAlertViewDelegate> delegate;
@property (strong, nonatomic) void(^completion)(void);
@end

@implementation SocialInvitationsViewController

- (id)initWithDelegate:(id<UIAlertViewDelegate>)delegate {
    self = [super initWithNibName:@"SocialInvitationsViewController" bundle:[NSBundle mainBundle]];
    self.viewControllers = @[];
    self.buttons = @[];
    self.delegate = delegate;
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"FIND FRIENDS";
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem rightBarButtonItemWithImage:[UIImage imageNamed:@"InviteCloseBtn"] target:self action:@selector(close)];
    
    SocialContactsViewController *contacts = [[SocialContactsViewController alloc] initWithDelegate:self];
    SocialFollowTableViewController *facebook = [[SocialFollowTableViewController alloc] initForProvider:@"facebook" delegate:self];
    SocialFollowTableViewController *twitter = [[SocialFollowTableViewController alloc] initForProvider:@"twitter" delegate:self];
    
    [self addViewController:contacts title:@"Contacts"];
    [self addViewController:facebook title:@"Facebook"];
    [self addViewController:twitter title:@"Twitter"];
    
    __unsafe_unretained SocialInvitationsViewController *weakSelf = self;
    
    self.completion = ^(void) {
        if (![UserManager sharedInstance].user.phone || [[UserManager sharedInstance].user.phone isEqualToString:@""]) {
            
            
            NSInteger count = [[[NSUserDefaults standardUserDefaults] objectForKey:@"PhoneNumberNagCount"] integerValue];
            
            if (count >= 2)
                return;
            
            
            NSString *cancelButtonTitle;
            
            if (count == 0)
                cancelButtonTitle = @"No Thanks";
            else
                cancelButtonTitle = @"Never";
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Phone Number" message:@"Make it easier for friends to find you on Knoda by entering your phone number. You can always add or remove your number in Profile Settings." delegate:weakSelf.delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:@"Save", nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            [[alert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
            [alert show];
        }
    };
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.scrollIndicator.hidden = YES;
}

- (void)close {
    if (self.inviteCount || self.followCount) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hold Up!" message:[NSString stringWithFormat:@"You have %ld pending invites & %ld follows, would you like to send these now?", (long)self.inviteCount, (long)self.followCount] delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Send", nil];
        [alert show];
    } else
        [self dismissViewControllerAnimated:YES completion:self.completion];
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == alertView.cancelButtonIndex)
        [self dismissViewControllerAnimated:YES completion:self.completion];
    else
        [self submit:nil];
}

- (void)selectionUpdatedInViewController:(SocialFollowTableViewController *)viewController {
    NSInteger invitations = 0;
    NSInteger selectedMatches = 0;
    
    for (UIViewController *vc in self.viewControllers) {
        if ([vc respondsToSelector:@selector(selectedMatches)])
            selectedMatches += [(id)vc selectedMatches].count;
        if ([vc respondsToSelector:@selector(invitations)])
            invitations += [(id) vc invitations].count;
    }
    
    self.followCount = selectedMatches;
    self.inviteCount = invitations;
    [self.followButton setTitle:[NSString stringWithFormat:@"Follow (%ld) & Invite (%ld)", (long)selectedMatches, (long)invitations] forState:UIControlStateNormal];
}

- (IBAction)submit:(id)sender {
    
    if (self.inviteCount == 0 && self.followCount == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"You haven't selected anyone to follow or invite yet." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    NSMutableArray *invitations = [NSMutableArray array];
    
    for (id vc in self.viewControllers) {
        if ([vc respondsToSelector:@selector(invitations)]) {
            NSArray *pending = [vc invitations];
            for (Contact *contact in pending) {
                Invitation *inv = [[Invitation alloc] init];
                inv.email = contact.selectedEmailAddress;
                inv.phoneNumber = contact.selectedPhoneNumber;
                [invitations addObject:inv];
            }
        }
        
    }
    
    NSMutableArray *followers = [NSMutableArray array];
    
    for (id vc in self.viewControllers) {
        if ([vc respondsToSelector:@selector(selectedMatches)]) {
            NSArray *pending = [vc selectedMatches];
            for (ContactMatch *match in pending) {
                Follower *follower = [[Follower alloc] init];
                follower.leaderId = match.info.userId;
                [followers addObject:follower];
            }
        }
        
    }
    
    [[LoadingView sharedInstance] show];
    
    [[WebApi sharedInstance] followUsers:followers completion:^(NSArray *results, NSError *error) {
        [[WebApi sharedInstance] sendInvites:invitations completion:^(NSArray *invitations, NSError *error) {
            [[LoadingView sharedInstance] hide];
            
            [[UserManager sharedInstance] refreshUser:^(User *user, NSError *error) {}];
            if (error) {
                [self dismissViewControllerAnimated:YES completion:self.completion];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Your invitations are on their way" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                [self dismissViewControllerAnimated:YES completion:self.completion];
            }
        }];
    }];
    

}

@end
