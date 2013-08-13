//
//  PredictionStatusCell.m
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 8/12/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "PredictionStatusCell.h"
#import "Prediction.h"
#import "Chellange.h"

#import "UILabel+Utils.h"

#define WIN_COLOR   [UIColor colorWithRed:30.0/255.0 green:92.0/255.0 blue:55.0/255.0 alpha:1.0]
#define LOSE_COLOR  [UIColor colorWithRed:160.0/255.0 green:34.0/255.0 blue:38.0/255.0 alpha:1.0]
#define POINTS_FONT [UIFont boldSystemFontOfSize:17]

static const float kCellBaseHeight     = 37.0;
static const float kTitleBottomPadding = 20.0;
static const float kBSTopPadding       = 10.0;
static const float kCellBottomPadding  = 10.0;
static const float kBSHeight           = 44.0;

@implementation PredictionStatusCell

- (void)setIsRight:(BOOL)isRight {
    _isRight = isRight;
    self.titleLabel.text      = isRight ? NSLocalizedString(@"YOU WON!", @"") : NSLocalizedString(@"YOU LOST!", @"");
    self.titleLabel.textColor = isRight ? WIN_COLOR : LOSE_COLOR;
}

- (IBAction)bsButtonTapped:(UIButton *)sender {
    
}

- (void)setupPoints:(Chellange *)challenge {
    self.pointsLabel.text = [[self class] buildPointsString:challenge];
    [self.pointsLabel sizeToFitText];
    self.pointsLabel.hidden = self.pointsLabel.text.length == 0;
}

- (void)adjustLayouts {
    if(!self.bsView.hidden) {
        float y = self.pointsLabel.hidden ? CGRectGetMinY(self.pointsLabel.frame) : (CGRectGetMaxY(self.pointsLabel.frame) + kBSTopPadding);
        CGRect frame = self.bsView.frame;
        frame.origin.y = y;
        self.bsView.frame = frame;
    }
}

- (void)setupCellWithPrediction:(Prediction *)prediction {
    self.isRight = prediction.chellange.isRight;
    [self setupPoints:prediction.chellange];
    self.bsView.hidden = prediction.chellange.isOwn;
    [self adjustLayouts];
}

+ (NSString *)buildPointsString:(Chellange *)challenge {
    __block NSMutableString *string = [NSMutableString string];
    
    void (^addPoint)(int, NSString*, NSString*) = ^(int point, NSString *singleName, NSString *plName) {
        if(point > 0) {
            BOOL single = point == 1;
            [string appendFormat:@"+%d %@\n", point, single ? singleName : plName];
        }
    };
    
    addPoint(challenge.basePoints, NSLocalizedString(@"Base point", @""), NSLocalizedString(@"Base points", @""));
    addPoint(challenge.outcomePoints, NSLocalizedString(@"Outcome point", @""), NSLocalizedString(@"Outcome points", @""));
    addPoint(challenge.marketSizePoints, NSLocalizedString(@"Market size point", @""), NSLocalizedString(@"Market size points", @""));
    addPoint(challenge.predictionMarketPoints, NSLocalizedString(@"Prediction market point", @""), NSLocalizedString(@"Prediction market points", @""));
    
    return string;
}

+ (CGFloat)heightForPrediction:(Prediction *)prediction {
    float height = kCellBaseHeight + kTitleBottomPadding;
    
    NSString *points = [self buildPointsString:prediction.chellange];
    if(points.length) {
        height += [points sizeWithFont:POINTS_FONT constrainedToSize:CGSizeMake(320, FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping].height;
        height += kBSTopPadding;
    }
    
    if(!prediction.chellange.isOwn) {
        height += kBSHeight;
    }
    
    height += kCellBottomPadding;
    
    return height;
}

@end
