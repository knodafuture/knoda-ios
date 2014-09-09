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

@interface SocialInvitationsViewController () <SocialFollowTableViewControllerDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (assign, nonatomic) NSInteger followCount;
@property (assign, nonatomic) NSInteger inviteCount;
@end

@implementation SocialInvitationsViewController

- (id)init {
    self = [super initWithNibName:@"SocialInvitationsViewController" bundle:[NSBundle mainBundle]];
    self.viewControllers = @[];
    self.buttons = @[];
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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.scrollIndicator.hidden = YES;
}

- (void)close {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hold Up!" message:[NSString stringWithFormat:@"You have %ld pending invites & %ld follows, would you like to send these now?", (long)self.inviteCount, (long)self.followCount] delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Send", nil];
    [alert show];
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == alertView.cancelButtonIndex)
        [self dismissViewControllerAnimated:YES completion:nil];
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
            if (error) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Your invitations are on their way" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }];
    }];
    

}

@end
