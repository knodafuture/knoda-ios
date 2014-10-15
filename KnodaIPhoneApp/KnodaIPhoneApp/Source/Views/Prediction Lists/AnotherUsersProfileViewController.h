//
//  ProfileMainViewController.h
//  KnodaIPhoneApp
//
//  Created by Vyacheslav Nechiporenko on 8/21/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "PredictionsViewController.h"
@interface AnotherUsersProfileViewController : PredictionsViewController

- (id)initWithUserId:(NSInteger)userId;
- (id)initWithUSername:(NSString *)username;
@end
