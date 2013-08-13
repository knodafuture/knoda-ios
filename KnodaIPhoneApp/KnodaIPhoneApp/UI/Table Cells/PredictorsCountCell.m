//
//  PredictorsCountCell.m
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 8/13/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "PredictorsCountCell.h"

@implementation PredictorsCountCell

- (void)setAgreedCount:(NSUInteger)agreedCount {
    self.agreedLabel.text = [NSString stringWithFormat:@"%d %@", agreedCount, NSLocalizedString(@"agreed", 0)];
}

- (void)setDisagreedCount:(NSUInteger)disagreedCount {
    self.disagreedLabel.text = [NSString stringWithFormat:@"%d %@", disagreedCount, NSLocalizedString(@"disagreed", 0)];
}

+ (CGFloat)cellHeight {
    return 30.0;
}

@end
