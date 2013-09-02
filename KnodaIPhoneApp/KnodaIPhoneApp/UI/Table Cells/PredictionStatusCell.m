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

@interface PredictionStatusCell()

@property (weak, nonatomic) IBOutlet UILabel  *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel  *pointsLabel;
@property (weak, nonatomic) IBOutlet UIView   *bsView;
@property (weak, nonatomic) IBOutlet UIButton *bsButton;

@end

@implementation PredictionStatusCell

- (void)setIsRight:(BOOL)isRight {
    _isRight = isRight;
    self.titleLabel.text      = isRight ? NSLocalizedString(@"YOU WON!", @"") : NSLocalizedString(@"YOU LOST!", @"");
    self.titleLabel.textColor = isRight ? WIN_COLOR : LOSE_COLOR;
}

- (void)setIsBS:(BOOL)isBS {
    _isBS = isBS;
    self.bsButton.highlighted = isBS;
    self.bsButton.userInteractionEnabled = !isBS;
}

- (void)setupPoints:(Chellange *)challenge {
    self.pointsLabel.text = [[self class] buildPointsString:challenge];
    [self.pointsLabel sizeToFitText];
    self.pointsLabel.hidden = self.pointsLabel.text.length == 0;
}

- (void)setLoading:(BOOL)loading {
    [super setLoading:loading];
    self.bsButton.selected = loading;
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
    self.isRight       = prediction.chellange.agree == prediction.outcome;
    self.bsView.hidden = prediction.chellange.isOwn;
    self.isBS          = prediction.chellange.isBS;
    [self setupPoints:prediction.chellange];
    [self adjustLayouts];
}

+ (NSString *)marketSizeNameForPoints:(NSInteger)points {
    switch (points) {
        case 0:  return NSLocalizedString(@"Too Easy", @"");
        case 10:
        case 20: return NSLocalizedString(@"Favorite", @"");
        case 30:
        case 40: return NSLocalizedString(@"Underdog", @"");
        case 50: return NSLocalizedString(@"Longshot", @"");
        default: return @"";
    }
}

+ (NSString *)buildPointsString:(Chellange *)challenge {
    __block NSMutableString *string = [NSMutableString string];
    
    void (^addPoint)(int, NSString*, NSString*, NSString*) = ^(int point, NSString *name, NSString *singlePoint, NSString *plPoint) {
        if(point > 0) {
            BOOL single = point == 1;
            [string appendFormat:@"+%d %@ %@\n", point, name, (single ? singlePoint : plPoint)];
        }
    };
    
    NSString *point = NSLocalizedString(@"Point", @"");
    NSString *points = NSLocalizedString(@"Points", @"");
    
    addPoint(challenge.basePoints, NSLocalizedString(@"Base", @""), point, points);
    addPoint(challenge.outcomePoints, NSLocalizedString(@"Outcome", @""), point, points);
    addPoint(challenge.marketSizePoints, NSLocalizedString(@"Market size", @""), point, points);
    addPoint(challenge.predictionMarketPoints, [self marketSizeNameForPoints:challenge.predictionMarketPoints], point, points);
    
    return string;
}

+ (CGFloat)cellHeightForPrediction:(Prediction *)prediction {
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
