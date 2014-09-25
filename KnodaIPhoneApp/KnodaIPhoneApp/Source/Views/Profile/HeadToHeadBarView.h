//
//  HeadToHeadBarView.h
//  KnodaIPhoneApp
//
//  Created by nick on 9/18/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>
@class User;
@interface HeadToHeadBarView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *leftImageView;
@property (weak, nonatomic) IBOutlet UILabel *leftLabel;
@property (weak, nonatomic) IBOutlet UIView *leftView;
@property (weak, nonatomic) IBOutlet UIImageView *rightImageView;
@property (weak, nonatomic) IBOutlet UILabel *rightLabel;
@property (weak, nonatomic) IBOutlet UIView *rightView;

@property (weak, nonatomic) IBOutlet UILabel *visitingUserLabel;
@property (weak, nonatomic) IBOutlet UILabel *homeUserLabel;

- (void)populateWithLeftUser:(User *)leftUser rightUser:(User *)rightUser animated:(BOOL)animated;

@end
