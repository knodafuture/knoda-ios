//
//  FollowersViewController.m
//  KnodaIPhoneApp
//
//  Created by nick on 9/1/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "FollowersViewController.h"
#import "FollowersTableViewController.h"    

@interface FollowersViewController ()
@property (assign, nonatomic) NSInteger userId;
@property (strong, nonatomic) NSString *name;
@end

@implementation FollowersViewController

- (id)initForUser:(NSInteger)userId name:(NSString *)name {
    self = [super init];
    self.userId = userId;
    self.name = name;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = self.name.uppercaseString;
    FollowersTableViewController *followers = [[FollowersTableViewController alloc] initAsLeader:YES forUser:self.userId];
    FollowersTableViewController *following = [[FollowersTableViewController alloc] initAsLeader:NO forUser:self.userId];
    
    [self addViewController:followers title:@"Followers"];
    [self addViewController:following title:@"Following"];
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backButtonWithTarget:self action:@selector(back)];
    
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
