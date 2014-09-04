//
//  FollowersTableViewController.h
//  KnodaIPhoneApp
//
//  Created by nick on 9/1/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "BaseTableViewController.h"

@interface FollowersTableViewController : BaseTableViewController

- (id)initAsLeader:(BOOL)asLeader forUser:(NSInteger)userId;
@end
