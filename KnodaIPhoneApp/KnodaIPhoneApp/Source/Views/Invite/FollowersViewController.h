//
//  FollowersViewController.h
//  KnodaIPhoneApp
//
//  Created by nick on 9/1/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "TabbedViewController.h"

@interface FollowersViewController : TabbedViewController

@property (assign, nonatomic) BOOL shouldShowSecondPage;
- (id)initForUser:(NSInteger)userId name:(NSString *)name;

@end
