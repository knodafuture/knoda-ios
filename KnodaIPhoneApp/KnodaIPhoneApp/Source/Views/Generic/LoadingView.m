//
//  LoadingView.m
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 04.09.13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "LoadingView.h"

@interface LoadingView() {
    int _counter;
}

@end

@implementation LoadingView

+ (instancetype)sharedInstance {
    static LoadingView *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil] lastObject];
    });
    return instance;
}

- (void)show {
    if(_counter++ == 0) {
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        self.frame = window.bounds;
        [window addSubview:self];
    }
}

- (void)hide {
    if(--_counter <= 0) {
        _counter = 0;
        [self removeFromSuperview];
    }
}

- (void)reset {
    [self removeFromSuperview];
    _counter = 0;
}

@end
