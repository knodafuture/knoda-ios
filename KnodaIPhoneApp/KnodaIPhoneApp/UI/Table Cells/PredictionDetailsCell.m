//
//  PredictionDetailsCell.m
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 13.08.13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "PredictionDetailsCell.h"
#import "UILabel+Utils.h"

#import "Prediction.h"
#import "Chellange.h"

#define BODY_FONT [UIFont fontWithName:@"HelveticaNeue" size:15.0]

static const float kBodyLabelMinHeight = 37.0;
static const float kBodyWidth          = 218.0;

@implementation PredictionDetailsCell

- (void)adjustLayouts {
    [self.bodyLabel sizeToFitText];
    CGRect frame = self.metadataLabel.frame;
    frame.origin.y = fmaxf(CGRectGetMaxY(self.bodyLabel.frame), kBodyLabelMinHeight);
    self.metadataLabel.frame = frame;
}

- (void)fillWithPrediction:(Prediction *)prediction {
    [super fillWithPrediction:prediction];
    [self adjustLayouts];
}

- (void)updateGuessMark {    
    if(self.prediction.chellange.isOwn) {
        [super updateGuessMark];
    }
    else if (self.prediction.hasOutcome && !self.prediction.chellange) {
        self.guessMarkImage.image = [UIImage imageNamed:(self.prediction.outcome ? @"check" : @"x_lost")];
    }
    else {
        self.guessMarkImage.image = nil;
    }
}

+ (CGFloat)cellHeightForPrediction:(Prediction *)prediction {
    float baseHeight = [self cellHeight];
    
    float bodyHeight = [prediction.body sizeWithFont:BODY_FONT constrainedToSize:CGSizeMake(kBodyWidth, FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping].height;
    
    if(bodyHeight > kBodyLabelMinHeight) {
        baseHeight += bodyHeight - kBodyLabelMinHeight;
    }
    
    return baseHeight;    
}

@end
