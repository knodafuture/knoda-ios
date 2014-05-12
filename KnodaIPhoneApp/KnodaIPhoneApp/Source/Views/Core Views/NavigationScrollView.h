//
//  NavigationScrollView.h
//  KnodaIPhoneApp
//
//  Created by nick on 12/13/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NavigationScrollView : UIScrollView

@property (assign, nonatomic) CGFloat bezelWidth;
@property (assign, nonatomic) BOOL disabled;
@property (weak, nonatomic) UIView *detailsView;

@end
