//
//  FirstStartView.h
//  KnodaIPhoneApp
//
//  Created by nick on 12/10/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FirstStartView;
@protocol FirstStartViewDelegate <NSObject>

- (void)firstStartViewDidClose:(FirstStartView *)firstStartView;

@end

@interface FirstStartView : UIView
@property (weak, nonatomic) id<FirstStartViewDelegate> delegate;

- (id)initWithDelegate:(id<FirstStartViewDelegate>)delegate;

@end
