//
//  NewPrediction+Utils.m
//  KnodaIPhoneApp
//
//  Created by nick on 12/6/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "Prediction+Utils.h"
#import "Challenge.h"
#import "NSData+Utils.h"
#import "PredictionPoints.h"

@implementation Prediction (Utils)

- (BOOL)isExpired {
    return [self.expirationDate timeIntervalSinceNow] < 0;
}

- (BOOL)isFinished {
    return self.challenge.isOwn && [self.resolutionDate timeIntervalSinceNow] < 0;
}

- (BOOL)passed72HoursSinceExpiration {
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.resolutionDate];
    NSTimeInterval secondsIn72Hours = 60 * 60 * 72;
    
    if (timeInterval > secondsIn72Hours)
        return YES;
    
    return NO;
}

- (BOOL)canSetOutcome {
    return self.challenge && ([self isFinished] || [self passed72HoursSinceExpiration]);
}

- (NSString *)metaDataString {
    
    CGFloat agreedFloat = ((CGFloat)self.agreeCount / (CGFloat)(self.agreeCount+self.disagreeCount));
    NSInteger agreedPercent = agreedFloat * 100;
    
    return [NSString stringWithFormat: NSLocalizedString(@"%@ | %@ | %d%% agree |", @""),
            self.expirationString,
            self.creationString,
             agreedPercent];
}
#pragma mark Calculate dates

- (BOOL)iAgree {
    return (self.challenge != nil) && (self.challenge.agree);
}

- (BOOL)iDisagree {
    return (self.challenge != nil) && !(self.challenge.agree);
}

- (UIImage *)statusImage {
    if (self.challenge.isOwn)
        return nil;
    if ([self iAgree])
        return [UIImage imageNamed:@"AgreeMarker"];
    else if ([self iDisagree])
        return [UIImage imageNamed:@"DisagreeMarker"];
    else
        return nil;
}

- (NSString *)outcomeString {
    if ([self iAgree])
        return self.outcome ? @"W" : @"L";
    else if ([self iDisagree])
        return self.outcome ? @"L" : @"W";
    return nil;
}
- (BOOL)win {
    if ([self iAgree])
        return self.outcome ? YES : NO;
    else
        return self.outcome ? NO : YES;
}
- (NSString *)pointsString {
    __block NSMutableString *string = [NSMutableString string];
    
    void (^addPoint)(NSInteger, NSString*) = ^(NSInteger point, NSString *name) {
        if(point > 0) {
            [string appendFormat:@"+%ld %@\n", (long)point, name];
        }
    };
    
    addPoint(self.points.basePoints, NSLocalizedString(@"Base", @""));
    addPoint(self.points.outcomePoints, NSLocalizedString(@"Outcome", @""));
    addPoint(self.points.marketSizePoints, NSLocalizedString(@"Market", @""));
    addPoint(self.points.predictionMarketPoints, [self marketSizeNameForPoints:self.points.predictionMarketPoints]);
    
    return string;
}
- (NSInteger)totalPoints {
    return self.points.basePoints + self.points.outcomePoints + self.points.marketSizePoints + self.points.predictionMarketPoints;
}
- (NSString *)marketSizeNameForPoints:(NSInteger)points {
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
@end
