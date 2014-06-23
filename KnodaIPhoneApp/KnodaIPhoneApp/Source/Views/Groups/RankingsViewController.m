//
//  RankingsViewController.m
//  KnodaIPhoneApp
//
//  Created by nick on 3/24/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "RankingsViewController.h"
#import "RankingsTableViewController.h"

@interface RankingsViewController ()
@property (strong, nonatomic) Group *group;

@end

@implementation RankingsViewController

- (id)initWithGroup:(Group *)group {
    self = [super init];
    self.group = group;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backButtonWithTarget:self action:@selector(back)];
    self.title = @"RANKINGS";
    RankingsTableViewController *weekly = [[RankingsTableViewController alloc] initWithGroup:self.group location:nil];
    RankingsTableViewController *monthly = [[RankingsTableViewController alloc] initWithGroup:self.group location:@"monthly"];
    RankingsTableViewController *allTime = [[RankingsTableViewController alloc] initWithGroup:self.group location:@"alltime"];
    
    
    [self addViewController:weekly title:@"7 DAY"];
    [self addViewController:monthly title:@"30 DAY"];
    [self addViewController:allTime title:@"ALL-TIME"];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}



@end
