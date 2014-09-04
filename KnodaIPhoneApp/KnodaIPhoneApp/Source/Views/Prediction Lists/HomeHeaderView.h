//
//  HomeHeaderView.h
//  KnodaIPhoneApp
//
//  Created by nick on 8/28/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HomeHeaderView;
@protocol HomeHeaderViewDelegate <NSObject>

- (void)leftSideTappedInHeaderView:(HomeHeaderView *)headerView;
- (void)rightSideTappedInHeaderView:(HomeHeaderView *)headerView;

@end

@interface HomeHeaderView : UIView
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) id<HomeHeaderViewDelegate> delegate;

- (id)initWithDelegate:(id<HomeHeaderViewDelegate>)delegate firstName:(NSString *)name secondName:(NSString *)name2;
@end
