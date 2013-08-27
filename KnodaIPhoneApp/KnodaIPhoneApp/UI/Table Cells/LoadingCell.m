//
//  LoadingCell.m
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 13.08.13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "LoadingCell.h"

@interface LoadingCell()

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation LoadingCell

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.activityIndicator startAnimating];
}

@end
