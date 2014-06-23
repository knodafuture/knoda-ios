//
//  NewActivityViewController.m
//  KnodaIPhoneApp
//
//  Created by nick on 6/22/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "NewActivityViewController.h"
#import "ActivityViewController.h"

@interface NewActivityViewController ()

@end

@implementation NewActivityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"ACTIVITY";
    
    
    ActivityViewController *allActivityItems = [[ActivityViewController alloc] initWithStyle:UITableViewStylePlain];
    ActivityViewController *expiredItems = [[ActivityViewController alloc] initWithStyle:UITableViewStylePlain];
    ActivityViewController *commentItems = [[ActivityViewController alloc] initWithStyle:UITableViewStylePlain];
    ActivityViewController *inviteItems = [[ActivityViewController alloc] initWithStyle:UITableViewStylePlain];
    
    
    [self addViewController:allActivityItems title:@"All"];
    [self addViewController:expiredItems title:@"Expired"];
    [self addViewController:commentItems title:@"Comments"];
    [self addViewController:inviteItems title:@"Invites"];
    
}

@end
