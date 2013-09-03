//
//  ParentViewController.h
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 02.09.13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChildControllerDataSource.h"
#import "ChildViewController.h"

@interface ParentViewController : UIViewController <ChildControllerDataSource>

@property (nonatomic, strong) IBOutlet UIView* detailsView;
@property (nonatomic, weak)   IBOutlet UIView *noContentView;
@property (nonatomic, strong) IBOutlet UIImageView* segmentedControlImage;

- (IBAction) lerfButtonPressed: (id) sender;
- (IBAction) rightButtonPressed: (id) sender;

@end
