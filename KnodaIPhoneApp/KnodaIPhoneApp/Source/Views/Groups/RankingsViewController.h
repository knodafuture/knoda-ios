//
//  RankingsViewController.h
//  KnodaIPhoneApp
//
//  Created by nick on 3/24/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Group;
@interface RankingsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

- (id)initWithGroup:(Group *)group;

@end
