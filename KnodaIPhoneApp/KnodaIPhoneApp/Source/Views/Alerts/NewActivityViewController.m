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
    
    
    ActivityViewController *allActivityItems = [[ActivityViewController alloc] initWithFilter:nil];
    ActivityViewController *expiredItems = [[ActivityViewController alloc] initWithFilter:@"expired"];
    ActivityViewController *commentItems = [[ActivityViewController alloc] initWithFilter:@"comments"];
    ActivityViewController *inviteItems = [[ActivityViewController alloc] initWithFilter:@"invites"];
    
    
    [self addViewController:allActivityItems title:@"All"];
    [self addViewController:expiredItems title:@"Expired"];
    [self addViewController:commentItems title:@"Comments"];
    [self addViewController:inviteItems title:@"Invites"];
    
}

@end
