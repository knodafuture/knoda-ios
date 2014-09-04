//
//  NewHomeViewController.h
//  KnodaIPhoneApp
//
//  Created by nick on 8/28/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewHomeViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

- (UITableView *)tableView;
@end
