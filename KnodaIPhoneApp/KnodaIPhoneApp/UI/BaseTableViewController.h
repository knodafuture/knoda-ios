//
//  BaseTableViewController.h
//  KnodaIPhoneApp
//
//  Created by Nick R on 11/22/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NoContentCell;
@interface BaseTableViewController : UITableViewController


- (void)showNoContent:(NoContentCell *)noContentCell;
- (void)restoreContent;

@end
