//
//  LoadableCell.m
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 15.08.13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "LoadableCell.h"

@implementation LoadableCell

- (void)setLoading:(BOOL)loading {
    _loading = loading;
    self.loadingView.hidden = !loading;
    if(loading) {
        [self.activityIndicator startAnimating];
    }
}

@end
