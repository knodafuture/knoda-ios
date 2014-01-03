//
//  RightSideButtonsView.m
//  KnodaIPhoneApp
//
//  Created by nick on 1/2/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "RightSideButtonsView.h"

@implementation RightSideButtonsView

- (id)init {
    UINib *nib = [UINib nibWithNibName:@"RightSideButtonsView" bundle:[NSBundle mainBundle]];
    
    self = [[nib instantiateWithOwner:nil options:nil] lastObject];
    
    return self;
}

- (void)setAddPredictionTarget:(id)target action:(SEL)action {
    [self.addPredictionButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

- (void)setSearchTarget:(id)target action:(SEL)action {
    [self.searchButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

- (void)setSearchButtonHidden:(BOOL)hidden {
    self.searchButton.hidden = hidden;
    self.searchImageView.hidden = hidden;
}


@end
