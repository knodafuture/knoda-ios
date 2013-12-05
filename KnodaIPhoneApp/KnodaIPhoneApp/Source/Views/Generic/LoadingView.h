//
//  LoadingView.h
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 04.09.13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingView : UIView

+ (instancetype)sharedInstance;

- (void)show;
- (void)hide;
- (void)reset;

@end
