//
//  InvitationsViewController.m
//  KnodaIPhoneApp
//
//  Created by nick on 8/23/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "SocialInvitationsViewController.h"
#import "SocialFollowTableViewController.h"
#import "SocialContactsViewController.h"

@interface SocialInvitationsViewController () <SocialFollowTableViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *followButton;
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.scrollIndicator.hidden = YES;
}

- (void)close {
    [self dismissViewControllerAnimated:YES completion:nil];
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
    
    [self.followButton setTitle:[NSString stringWithFormat:@"Follow (%ld) & Invite (%ld)", (long)selectedMatches, (long)invitations] forState:UIControlStateNormal];
}

@end
