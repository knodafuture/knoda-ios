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
    
    self.settingsButton.hidden = YES;
    self.settingsImageView.hidden = YES;
    
    return self;
}

- (void)setAddPredictionTarget:(id)target action:(SEL)action {
    [self.addPredictionButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

- (void)setSearchTarget:(id)target action:(SEL)action {
    [self.searchButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

-(void)setSettingsTarget:(id)target action:(SEL)action {
    [self.settingsButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}



- (void)setSearchButtonHidden:(BOOL)hidden {
    self.searchButton.hidden = hidden;
    self.searchImageView.hidden = hidden;
}

-(void)setbuttonsHidden:(BOOL)hidden {
    self.searchButton.hidden = hidden;
    self.searchImageView.hidden = hidden;
    self.addPredictionButton.hidden = hidden;
    self.addPredictionImageView.hidden = hidden;
    self.settingsButton.hidden = !hidden;
    self.settingsImageView.hidden = !hidden;
}

@end
