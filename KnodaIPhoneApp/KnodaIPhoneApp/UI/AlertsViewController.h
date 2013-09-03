//
//  AlertsViewController.h
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/25/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "ParentViewController.h"

@protocol RefreshableViewController <NSObject>

- (void) refresh;

@end

@interface AlertsViewController : ParentViewController

@end
